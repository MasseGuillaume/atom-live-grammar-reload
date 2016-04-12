path = require 'path'
pkg = require './package'

module.exports =
  configDefaults:
    enabled: true

  activate: ->
    return unless atom.inDevMode() && !atom.inSpecMode()
    atom.workspace.observeTextEditors (editor) =>
      editor.buffer.onDidSave =>
        @reload()

  reload: ->
    # return unless atom.config.get("#{pkg.name}.enabled")
    project = atom.project
    pkgPath = path.join(atom.project.rootDirectories[0].path, 'package.json')
    if project.contains(pkgPath)
      projectPkg = require(pkgPath)
      if projectPkg.engines? && projectPkg.engines.atom?
        for g in atom.grammars.grammars
          if (g?.packageName == projectPkg.name)
            atom.grammars.removeGrammar g

        delete atom.packages.loadedPackages[projectPkg.name] # force reload
        updatedPackage = atom.packages.loadPackage(projectPkg.name)
        updatedPackage.loadGrammarsSync()
        updatedPackage.grammars.forEach (g) ->
          atom.grammars.addGrammar g

        atom.workspace.observeTextEditors (editor) ->
          if editor.getGrammar().packageName == projectPkg.name
            editor.reloadGrammar()
