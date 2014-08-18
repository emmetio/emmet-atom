{$, EditorView, View} = require 'atom'

noop = ->

method = (delegate, method) ->
	delegate?[method]?.bind(delegate) or noop

module.exports = 
class PromptView extends View
	@attach: -> new PromptView

	@content: ->
		@div class: 'emmet-prompt tool-panel panel-bottom', =>
			# @label class: 'emmet-prompt__label', outlet: 'label'
			@div class: 'emmet-prompt__input', =>
				@subview 'panelInput', new EditorView(mini: true)

	initialize: () ->
		@panelEditor = @panelInput.getEditor()
		@panelEditor.on 'contents-modified', =>
			return unless @attached
			@handleUpdate @panelEditor.getText()
		@on 'core:confirm', => @confirm()
		@on 'core:cancel', => @cancel()

	show: (@delegate={}) ->
		@editor = @delegate.editor
		@editorView = @delegate.editorView
		@panelInput.setPlaceholderText @delegate.label or 'Enter abbreviation'
		@updated = no

		@attach()
		text = @panelEditor.getText()
		if text
			@handleUpdate text

	undo: ->
		@editor.undo() if @updated

	handleUpdate: (text) ->
		@undo()
		@updated = yes
		@editor.transact =>
			method(@delegate, 'update')(text)

	confirm: ->
		@handleUpdate @panelEditor.getText()
		@trigger 'confirm'
		method(@delegate, 'confirm')()
		@detach()

	cancel: ->
		@undo()
		@trigger 'cancel'
		method(@delegate, 'cancel')()
		@detach()
		
	detach: ->
		return unless @hasParent()
		@detaching = true
		# @panelView.setText('')

		if @previouslyFocusedElement?.isOnDom()
			@previouslyFocusedElement.focus()
		else
			atom.workspaceView.focus()

		super
		@detaching = false
		@attached = false

		@trigger 'detach'
		method(@delegate, 'hide')()

	attach: ->
		@attached = true
		@previouslyFocusedElement = $(':focus')
		# atom.workspaceView.append(this)
		atom.workspaceView.prependToBottom(this)
		@panelInput.focus()
		@trigger 'attach'
		method(@delegate, 'show')()
