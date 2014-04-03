{Point} = require 'atom'
path = require 'path'

emmet = require('emmet')
utilsCommon = require('emmet/lib/utils/common')
tabStops = require('emmet/lib/assets/tabStops')
resources = require('emmet/lib/assets/resources')
editorUtils = require('emmet/lib/utils/editor')
Dialog = require './dialog'

try
  snippetsPath = atom.packages.resolvePackagePath('snippets')
  snippets = require snippetsPath
  Snippet = require path.join(snippetsPath, 'lib/snippet')
  SnippetExpansion = require './snippet-expansion'
catch e
  console.error e

# Proprocess text data that should be used as snippet content
# Currently, Atom’s snippets implementation has the following issues: 
# * supports $N or ${N:placeholder} notation, but not ${N}
# * multiple $0 are not treated as distinct final tabstops
preprocessSnippet = (value) ->
  base = 1000
  zeroBase = 0
  lastZero = null

  tabstopOptions =
    tabstop: (data) ->
      group = parseInt(data.group, 10)
      if group is 0
        group = ++zeroBase
      else
        group += base

      placeholder = data.placeholder or ''
      if placeholder
        # recursively update nested tabstops
        placeholder = tabStops.processText(placeholder, tabstopOptions)

      if placeholder then "${#{group}:#{placeholder}" else "$#{group}"
      
    escape: (ch) ->
      if ch == '$' then '\\$' else ch

  tabStops.processText(value, tabstopOptions)

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

  # Inserts given text as snippet into current position
  insertAsSnippet: (text) ->
    unless snippets?
      return false

    # Normalize tabstops before passing it to Snippets module.
    text = preprocessSnippet(text)
    bodyTree = snippets.getBodyParser().parse(text)
    snippet = new Snippet({'__emmet', '', bodyTree, bodyText: text})
    new SnippetExpansion(snippet, @editor)

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

    value = editorUtils.normalize(value, {
      indentation: @editorView.editor.getTabText()
    })

    changeRange = [
      Point.fromObject(@editor.getBuffer().positionForCharacterIndex(start))
      Point.fromObject(@editor.getBuffer().positionForCharacterIndex(end))
    ]

    # If there’s a snippets module, use it to generate
    # proper tabstops in output
    if snippets?
      return @editor.transact =>
        @editor.getBuffer().change(changeRange, '')
        @setCaretPos start
        @insertAsSnippet value

    # XXX is it possible that Snippets module does not exists?
    # find new caret position
    tabstopData = tabStops.extract(value,
      escape: (ch) -> ch
      tabStop: () -> ''
    )
    firstTabStop = tabstopData.tabstops[0]
    value = tabstopData.text

    if firstTabStop
      firstTabStop.start += start
      firstTabStop.end += start
    else
      firstTabStop =
        start: value.length + start
        end: value.length + start

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
    grammar = @editor.getGrammar().name.toLowerCase()
    if /\b(less|scss|sass|css|stylus)\b/.test(grammar)
      return "css"
    else if /\b(html|xml|haml|slim)\b/.test(grammar)
      return "html"
    else
      return null

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
