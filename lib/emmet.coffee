CSON = require 'season'
fs = require 'fs'
path = require 'path'

emmet = require('../vendor/emmet-app').emmet
actions = emmet.require 'action/main'
resources = emmet.require 'assets/resources'
caniuse = emmet.require 'assets/caniuse'

emmet.define('file', require('./file'))

editorProxy = require './editor-proxy'

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

    @setupSnippets()

    @editorViewSubscription = atom.workspaceView.eachEditorView (editorView) =>
      if editorView.attached and not editorView.mini
        for action, emmetAction of @actionTranslation
          do (action) =>
              editorView.command action, (e) =>
                # a better way to do this might be to manage the editorProxies
                # right now we are setting up the proxy each time
                editorProxy.setupContext(editorView)
                syntax = editorProxy.getSyntax()
                if syntax
                  emmetAction = @actionTranslation[action]
                  if emmetAction == "expand_abbreviation_with_tab" && !editorView.getEditor().getSelection().isEmpty()
                    e.abortKeyBinding()
                    return
                  else
                    actions.run(emmetAction, editorProxy)
                else
                  e.abortKeyBinding()
                  return
  deactivate: ->
    @editorViewSubscription?.off()
    @editorViewSubscription = null


  # we must set these up here, so that the Node environment is loaded, and snippets work
  setupSnippets: ->
    defaultSnippets = fs.readFileSync(path.join(__dirname, '../vendor/snippets.json'), {encoding: 'utf8'})
    resources.setVocabulary(JSON.parse(defaultSnippets), 'system')

    db = fs.readFileSync(path.join(__dirname, '../vendor/caniuse.json'), {encoding: 'utf8'})
    caniuse.load(db)
