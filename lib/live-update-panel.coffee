{$, EditorView, Point, View} = require 'atom'
ContextPanelView = require './context-panel'

module.exports =
class LiveUpdatePanelView extends ContextPanelView
	@attach: -> new LiveUpdatePanelView
	@content: ->
		ContextPanelView.content.call(@)

	state: null
	initialize: (@editorView, @options={}) ->
		@_updated = no
		@_origOnupdate = @options.onupdate.bind(@options)
		super @editorView, $.extend {}, @options, onupdate: (text) =>
			@handleUpdate(text)

		@on 'cancel', =>
			@undo()

	# Remembers current selection state of underlying editor
	rememberState: ->
		@state = 
			selection: @editor.getSelectedBufferRange()
			text: @editor.getSelectedText()
			lastRange: null

	undo: ->
		@editor.undo()

	handleUpdate: (text) ->
		@undo() if @_updated
		@editor.transact =>
			@_updated = yes
			@_origOnupdate(text)
