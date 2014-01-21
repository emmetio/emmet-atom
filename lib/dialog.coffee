{$, EditorView, Point, View} = require 'atom'

module.exports =
class PromptView extends View

  @attach: -> new PromptView

  @content: ->
    @div class: 'emmet-prompt overlay from-top mini', =>
      @subview 'miniEditor', new EditorView(mini: true)
      @div class: 'message', outlet: 'message'

  detaching: false

  initialize: (@prompt, @callback, {@caller, @callerArgs, @callerContext}) ->
    @toggle()
    @miniEditor.hiddenInput.on 'focusout', => @detach() unless @detaching
    @on 'core:confirm', => @confirm()
    @on 'core:cancel', => @detach()

  toggle: ->
    if @hasParent()
      @detach()
    else
      @attach()

  detach: ->
    return unless @hasParent()

    @detaching = true
    @miniEditor.setText('')

    if @previouslyFocusedElement?.isOnDom()
      @previouslyFocusedElement.focus()
    else
      atom.workspaceView.focus()

    super

    @detaching = false
    @attached = false

  confirm: ->
    text = @miniEditor.getText()

    @detach()

    @callback(@message, @callerContext, text, @caller, @callerArgs)

  attach: ->
    @attached = true
    @previouslyFocusedElement = $(':focus')
    atom.workspaceView.append(this)
    @message.text(@prompt)
    @miniEditor.focus()
