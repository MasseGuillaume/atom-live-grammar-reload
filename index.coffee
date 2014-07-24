path = require 'path'
pkg = require './package'

module.exports =
  configDefaults:
    enabled: true

  activate: ->
    return unless atom.inDevMode() && !atom.inSpecMode()
    atom.workspaceView.eachEditorView (editorView) =>
      editorView.editor.getBuffer().on 'saved', =>
        @reload()

  reload: ->
    # return unless atom.config.get("#{pkg.name}.enabled")
    project = atom.project
    pkgPath = path.join(project.getPath(), 'package.json')
    if project.contains(pkgPath)
      projectPkg = require(pkgPath)
      if projectPkg.engines? && projectPkg.engines.atom?

        toRemove = atom.syntax.grammars
          .filter (g) -> return g.packageName == projectPkg.name
          .forEach (g) -> atom.syntax.removeGrammar(g)

        delete atom.packages.loadedPackages[projectPkg.name] # force reload
        updatedPackage = atom.packages.loadPackage(projectPkg.name)
        updatedPackage.loadGrammarsSync()
        updatedPackage.grammars.forEach (g) ->
            atom.syntax.addGrammar g

        atom.workspaceView.eachEditorView (editorView) ->
          if editorView.getEditor().getGrammar().packageName == projectPkg.name
            editorView.getEditor().reloadGrammar()
