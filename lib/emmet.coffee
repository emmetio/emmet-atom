CSON = require 'season'
path = require 'path'

emmet = require 'emmet'
editorProxy = require './editor-proxy'
ContextPanelView = require './context-panel'

module.exports =
  editorSubscription: null

  activate: (@state) ->
    unless @actionTranslation
      @actionTranslation = {}
      for selector, bindings of CSON.readFileSync(path.join(__dirname, "../keymaps/emmet.cson"))
        for key, action of bindings
          # Atom likes -, but Emmet expects _
          emmet_action = action.split(":")[1].replace(/\-/g, "_")
          @actionTranslation[action] = emmet_action

    @editorViewSubscription = atom.workspaceView.eachEditorView (editorView) =>
      if editorView.attached and not editorView.mini
        for action, emmetAction of @actionTranslation
          do (action) =>
              editorView.command action, (e) =>
                if emmetAction is 'show_panel'
                  panel = new ContextPanelView(editorView)
                  return

                # a better way to do this might be to manage the editorProxies
                # right now we are setting up the proxy each time
                editorProxy.setupContext(editorView)
                syntax = editorProxy.getSyntax() or 'html'
                if syntax
                  emmetAction = @actionTranslation[action]
                  if emmetAction == "expand_abbreviation_with_tab" && !editorView.getEditor().getSelection().isEmpty()
                    e.abortKeyBinding()
                    return
                  else
                    emmet.run(emmetAction, editorProxy)
                else
                  e.abortKeyBinding()
                  return
  deactivate: ->
    @editorViewSubscription?.off()
    @editorViewSubscription = null
