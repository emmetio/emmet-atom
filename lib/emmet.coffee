#_ = require 'underscore'
$ = require 'jquery'
emmet = require './emmet-core'
actions = emmet.require("actions")
editorProxy = require './editor-proxy'

module.exports =
  editorSubscription: null

  initialize: (@editor) ->

    debugger


  activate: (@state) ->
    @editorSubscription = rootView.eachEditor (editor) =>
      if editor.attached and not editor.mini
        editorProxy.setupContext(editor)
        rootView.command 'emmet:expand_abbreviation', =>
          @expandAbbreviation()

  expandAbbreviation: ->
    emmet.require("actions").run("expand_abbreviation", editorProxy)

  deactivate: ->
    @editorSubscription?.off()
    @editorSubscription = null
