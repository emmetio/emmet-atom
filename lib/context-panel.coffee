{$, EditorView, Point, View} = require 'atom'

module.exports =
class ContextPanelView extends View
	@attach: -> new ContextPanelView

	@content: ->
		@div class: 'emmet-panel mini', =>
			@subview 'panelView', new EditorView(mini: true)
			@div class: 'emmet-panel-tail'

	initialize: (@editorView, @options={}) ->
		{@editor} = @editorView
		@panelEditor = @panelView.getEditor()
		@panelView.setPlaceholderText 'Enter Abbreviation'
		@panelView.setFontSize 11
		@panelEditor.on 'contents-modified', =>
			console.log 'modified', @panelEditor.getText()
			@options.onupdate?(@panelEditor.getText())
		# @panelView.hiddenInput.on 'focusout', => @detach() unless @detaching
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
		@panelView.setText('')

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
			top: viewRect.top + selPixelPos.top - @height() - 15
			left: viewRect.left + selPixelPos.left - 15
		})
		
		@panelView.focus()