{Point} = require 'atom'

emmet = require('../vendor/emmet-app').emmet
utilsCommon = emmet.require('utils/common')
tabStops = emmet.require('assets/tabStops')
resources = emmet.require("assets/resources")
Dialog = require './dialog'

module.exports =
  setupContext: (@editorView) ->
    @editor = @editorView.getEditor()
    @indentation = @editor.getTabText()
    resources.setVariable("indentation", @indentation)
    @syntax = @getSyntax()

  # Fetches the character indexes of the selected text.
  #
  # Returns an {Object} with `start` and `end` properties.
  getSelectionRange: ->
    range = @editor.getSelection().getBufferRange()
    return {
      start: @editor.getBuffer().characterIndexForPosition(range.start),
      end: @editor.getBuffer().characterIndexForPosition(range.end)
    }

  # Creates a selection from the `start` to `end` character indexes.
  #
  # If `end` is ommited, this method should place a caret at the `start` index.
  #
  # start - A {Number} representing the starting character index
  # end - A {Number} representing the ending character index
  createSelection: (start, end) ->
    @editor.getSelection().setBufferRange
      start: @editor.getBuffer().positionForCharacterIndex(start)
      end: @editor.getBuffer().positionForCharacterIndex(end)

  # Fetches the current line's start and end indexes.
  #
  # Returns an {Object} with `start` and `end` properties
  getCurrentLineRange: ->
    row = @editor.getCursor().getBufferRow()
    lineLength = @editor.lineLengthForBufferRow(row)
    index = @editor.getBuffer().characterIndexForPosition({row: row, column: 0})
    return {
      start: index,
      end: index + lineLength
    }

  # Returns the current caret position.
  getCaretPos: ->
    row = @editor.getCursor().getBufferRow()
    column = @editor.getCursor().getBufferColumn()
    return @editor.getBuffer().characterIndexForPosition( {row: row, column: column} )

  # Sets the current caret position.
  setCaretPos: (index) ->
    pos = @editor.getBuffer().positionForCharacterIndex(index)
    @editor.getSelection().clear()
    @editor.setCursorBufferPosition pos

  # Returns the current line.
  getCurrentLine: ->
    row = @editor.getCursor().getBufferRow()
    return @editor.lineForBufferRow(row)

  # Replace the editor's content (or part of it, if using `start` to
  # `end` index).
  #
  # If `value` contains `caret_placeholder`, the editor puts a caret into
  # this position. If you skip the `start` and `end` arguments, the whole target's
  # content is replaced with `value`.
  #
  # If you pass just the `start` argument, the `value` is placed at the `start` string
  # index of thr current content.
  #
  # If you pass both `start` and `end` arguments, the corresponding substring of
  # the current target's content is replaced with `value`.
  #
  # value - A {String} of content you want to paste
  # start - The optional start index {Number} of the editor's content
  # end - The optional end index {Number} of the editor's content
  # noIdent - An optional {Boolean} which, if `true`, does not attempt to auto indent `value`
  replaceContent: (value, start, end, noIndent) ->
    if !end?
      end = if !start? then @getContent().length else start
    start = 0 unless start?

    # # indent new value
    unless noIndent
      value = utilsCommon.padString(value, utilsCommon.getLinePaddingFromPosition(@getContent(), start))

    # find new caret position
    tabstopData = tabStops.extract(value,
      escape: (ch) ->
        return ch
    )
    # emmet uses hardcoded \t for indents, with no optional override
    value = tabstopData.text.replace(/\t/g, @editorView.editor.getTabText())
    firstTabStop = tabstopData.tabstops[0]

    if firstTabStop
      firstTabStop.start += start
      firstTabStop.end += start
    else
      firstTabStop =
        start: value.length + start
        end: value.length + start

    changeRange = [
      Point.fromObject(@editor.getBuffer().positionForCharacterIndex(start))
      Point.fromObject(@editor.getBuffer().positionForCharacterIndex(end))
    ]

    @editor.getBuffer().change(changeRange, value)

    # handles where to place the cursor after the replacement
    cursorRange = {}
    cursorRange.start = Point.fromObject(@editor.getBuffer().positionForCharacterIndex(firstTabStop.start))
    cursorRange.end = Point.fromObject(@editor.getBuffer().positionForCharacterIndex(firstTabStop.end))

    # passes the cursor along when tabbing normally
    unless value == @editor.getTabText()
      @editor.getSelection().setBufferRange(cursorRange)

  # Returns the editor content.
  getContent: ->
    return @editor.getText()

  # Returns the editor's syntax mode.
  getSyntax: ->
    scopes = @editor.getCursorScopes()
    for scope in scopes
      if /html/.test(scope)
        return "html"
      else if /css/.test(scope)
        return "css"

  # Returns the current output profile name
  #
  # See emmet.setupProfile for more information.
  getProfileName: ->
    return @editor.getGrammar().name

  # Returns the currently selected text.
  getSelection: ->
    return @editor.getSelectedText()

  # Returns the current editor's file path
  getFilePath: ->
    # is there a better way to get this?
    return @editor.buffer.file.path

  setSavedText: (text) ->
    @savedText = text

  getSavedText: ->
    @savedText

  # all of this caller hackery is because emmet expects a synchronous, blocking
  # prompt dialog, as is the case with window.prompt. N.B. that emmet-app has
  # been modified to pass 'callerContext' to all prompt calls
  prompt: (message, callerContext, text=null, caller=null, callerArgs=null) ->
    if text != null
      callerArgs[0].setSavedText(text)
      caller.apply(callerContext, callerArgs)
    else if @getSavedText()?
      copy = @getSavedText()
      @setSavedText(null)
      copy
    else
      caller = arguments.callee.caller
      callerArgs = caller.arguments
      new Dialog message, @prompt, {caller, callerArgs, callerContext}
      return "" # bluff emmet's expecttaion of prompt for now
