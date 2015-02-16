{$, TextEditorView, View} = require 'atom-space-pen-views'
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
				@subview 'panelInput', new TextEditorView(mini: true)

	initialize: () ->
		@panelEditor = @panelInput.getModel()
		@panelEditor.onDidStopChanging =>
			return unless @attached
			@handleUpdate @panelEditor.getText()
		atom.commands.add @panelInput.element, 'core:confirm', => @confirm()
		atom.commands.add @panelInput.element, 'core:cancel', => @cancel()

	show: (@delegate={}) ->
		@editor = @delegate.editor
		@editorView = @delegate.editorView
		# @panelInput.setPlaceholderText @delegate.label or 'Enter abbreviation'
		@panelInput.element.setAttribute 'placeholder', @delegate.label or 'Enter abbreviation'
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
		@prevPane?.activate()

		super
		@detaching = false
		@attached = false

		@trigger 'detach'
		method(@delegate, 'hide')()

	attach: ->
		@attached = true
		@prevPane = atom.workspace.getActivePane()
		atom.workspace.addBottomPanel(item: this, visible: true)
		@panelInput.focus()
		@trigger 'attach'
		method(@delegate, 'show')()
