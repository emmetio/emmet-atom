emmet = require '../vendor/emmet-core'
utils = emmet.require("utils")

module.exports =
  @editor: null
  @syntax: null

  setupContext: (editor) ->
    @editor = editor
    @indentation = @editor.activeEditSession.getTabText()
    emmet.require("resources").setVariable("indentation", @indentation)

    @syntax = @getSyntax()

  # Fetches the character indexes of the selected text.
  #
  # Returns an {Object} with `start` and `end` properties.
  getSelectionRange: ->
    range = @editor.getSelection().getBufferRange()
    return {
      start: @editor.activeEditSession.indexForBufferPosition(range.start),
      end: @editor.activeEditSession.indexForBufferPosition(range.end)
    }

  # Fetches the current line's start and end indexes.
  #
  # Returns an {Object} with `start` and `end` properties
  getCurrentLineRange: ->
    row = @editor.getCursor().getBufferRow()
    lineLength = @editor.lineLengthForBufferRow(row)
    index = @editor.activeEditSession.indexForBufferPosition({row: row, column: 0})
    return {
      start: index,
      end: index + lineLength
    }

  getCaretPos: ->
    row = @editor.getCursor().getBufferRow()
    column = @editor.getCursor().getBufferColumn()

    return @editor.activeEditSession.indexForBufferPosition( {row: row, column: column} )

  getContent: ->
    @editor.getText()

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
      value = utils.padString(value, utils.getLinePaddingFromPosition(@getContent(), start))

    # find new caret position
    tabstopData = emmet.require("tabStops").extract(value,
      escape: (ch) ->
        return ch
    )
    value = tabstopData.text
    firstTabStop = tabstopData.tabstops[0]

    if firstTabStop
      firstTabStop.start += start
      firstTabStop.end += start
    else
      firstTabStop =
        start: value.length + start
        end: value.length + start

    range = @editor.getSelection()
    range.start = @editor.activeEditSession.indexForBufferPosition(start)
    range.end = @editor.activeEditSession.indexForBufferPosition(end)

    range.insertText(value)

    range.start = @editor.activeEditSession.indexForBufferPosition(firstTabStop.start)
    range.end = @editor.activeEditSession.indexForBufferPosition(firstTabStop.end)
    @editor.setSelectedBufferRange(range)

  getSyntax: ->
    @syntax if @syntax

    "html"

  getProfileName: ->
    switch @getSyntax()
      when "css"
        return "css"
      when "xml", "xsl"
        return "xml"
      else
        return "xhtml"
