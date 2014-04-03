{$, EditorView, Point, View} = require 'atom'
ContextPanelView = require './context-panel'

module.exports =
class LiveUpdatePanelView extends ContextPanelView
	@attach: -> new LiveUpdatePanelView
	@content: ->
		ContextPanelView.content.call(@)

	state: null
	initialize: (@editorView, @options={}) ->
		@erase = no
		@_origOnupdate = @options.onupdate.bind(@options)
		super @editorView, $.extend {}, @options, onupdate: (text) =>
			@handleUpdate(text)

	# Remembers current selection state of underlying editor
	rememberState: ->
		@state = 
			selection: @editor.getSelectedBufferRange()
			text: @editor.getSelectedText()
			lastRange: null

	undo: ->
		console.log 'undo'
		@editor.undo()

	handleUpdate: (text) ->
		if not text and @erase
			@undo()
			@erase = no
			return

		@undo()
		@editor.transact =>
			console.log 'update'
			@_origOnupdate(text)
			@erase = yes
