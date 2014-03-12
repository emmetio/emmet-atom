{$, EditorView, Point, View} = require 'atom'

module.exports =
class ContextPanelView extends View
	@attach: -> new ContextPanelView

	@content: ->
		@div class: 'emmet-panel mini', =>
			@subview 'panelEditor', new EditorView(mini: true)

	initialize: (@editorView, @options={}) ->
		console.log 'Context panel inited'
		@editor = @editorView.getEditor()
		@panelEditor.setPlaceholderText 'Enter Abbreviation'
		# @panelEditor.setFontSize 10
		@panelEditor.on 'textInput', =>
			console.log 'Text input', @editor.getText()
		# @panelEditor.hiddenInput.on 'focusout', => @detach() unless @detaching
		@on 'core:confirm', => @confirm()
		@on 'core:cancel', => @detach()

		@toggle()

	toggle: ->
		if @hasParent()
			@detach()
		else
			@attach()

	confirm: ->
		console.log 'Confirm'
		@detach()
		
	detach: ->
		return unless @hasParent()
		console.log 'Detaching'
		@detaching = true
		@panelEditor.setText('')

		if @previouslyFocusedElement?.isOnDom()
			@previouslyFocusedElement.focus()
		else
			atom.workspaceView.focus()

		super

		@detaching = false
		@attached = false

	getEditorViewRect: ->
		@editorView.find('.scroll-view').get(0).getBoundingClientRect()

	attach: ->
		@attached = true
		@previouslyFocusedElement = $(':focus')

		selRange = @editor.getSelectedBufferRange()
		selPixelPos = @editorView.pixelPositionForBufferPosition selRange.start
		viewRect = @getEditorViewRect()

		atom.workspaceView.append(this)
		
		# align panel with selection start
		@css({
			top: viewRect.top + selPixelPos.top - @height() - 5
			left: viewRect.left + selPixelPos.left - 5
		})
		
		@panelEditor.focus()