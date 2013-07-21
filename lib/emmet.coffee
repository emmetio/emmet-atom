CSON = require 'season'
path = require 'path'
emmet = require '../vendor/emmet-core'
actions = emmet.require("actions")
editorProxy = require './editor-proxy'

module.exports =
  editorSubscription: null

  activate: (@state) ->
    keymapObj = CSON.readFileSync(path.join(__dirname, "../keymaps/emmet.cson"))[".editor"]
    @editorSubscription = rootView.eachEditor (editor) =>
      if editor.attached and not editor.mini
        editorProxy.setupContext(editor)
        for own key of keymapObj
          action = keymapObj[key]
          emmet_action = action.split(":")[1]

          # Atom likes -, but Emmet expects _
          rootView.command action, =>
            actions.run(emmet_action.replace(/\-/g, "_"), editorProxy)

  deactivate: ->
    @editorSubscription?.off()
    @editorSubscription = null
