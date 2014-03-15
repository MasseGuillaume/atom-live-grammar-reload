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
    return unless atom.config.get("#{pkg.name}.enabled")
    project = atom.project
    pkgPath = path.join(project.getPath(), 'package.json')
    if project.contains(pkgPath)
      projectPkg = require(pkgPath)
      if projectPkg.engines? && projectPkg.engines.atom?
        atom.reload()