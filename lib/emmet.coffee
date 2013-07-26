CSON = require 'season'
path = require 'path'
emmet = require '../vendor/emmet-core'
editorProxy = require './editor-proxy'
actions = emmet.require("actions")
emmet.define('file', require('./file'));

module.exports =
  editorSubscription: null

  activate: (@state) ->
    keymapObj = CSON.readFileSync(path.join(__dirname, "../keymaps/emmet.cson"))[".editor"]

    @editorSubscription = rootView.eachEditor (editor) =>
      if editor.attached and not editor.mini
        editorProxy.setupContext(editor)

        for key of keymapObj
          # Atom likes -, but Emmet expects _
          action = keymapObj[key]
          emmet_action = action.split(":")[1].replace(/\-/g, "_")

          do (action, emmet_action) ->
            rootView.command action, =>
              actions.run(emmet_action, editorProxy)

  deactivate: ->
    @editorSubscription?.off()
    @editorSubscription = null
