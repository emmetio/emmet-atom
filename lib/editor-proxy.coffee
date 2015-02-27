{Point, Range} = require 'atom'
path           = require 'path'

emmet       = require 'emmet'
utils       = require 'emmet/lib/utils/common'
tabStops    = require 'emmet/lib/assets/tabStops'
resources   = require 'emmet/lib/assets/resources'
editorUtils = require 'emmet/lib/utils/editor'

insertSnippet = (snippet, editor) ->
  atom.packages.getLoadedPackage('snippets')?.mainModule?.insert(snippet, editor)

  # Fetch expansions and assign to editor
  editor.snippetExpansion = atom.packages.getLoadedPackage('snippets')?.mainModule?.getExpansions(editor)[0]

visualize = (str) ->
  str
    .replace(/\t/g, '\\t')
    .replace(/\n/g, '\\n')
    .replace(/\s/g, '\\s')

# Normalizes text before it goes to editor: replaces indentation
# and newlines with ones used in editor
# @param  {String} text   Text to normalize
# @param  {Editor} editor Brackets editor instance
# @return {String}
normalize = (text, editor) ->
  editorUtils.normalize text,
    indentation: editor.getTabText(),
    newline: '\n'

# Proprocess text data that should be used as snippet content
# Currently, Atom’s snippets implementation has the following issues:
# * supports $N or ${N:placeholder} notation, but not ${N}
# * multiple $0 are not treated as distinct final tabstops
preprocessSnippet = (value) ->
  order = []

  tabstopOptions =
    tabstop: (data) ->
      group = parseInt(data.group, 10)
      if group is 0
        order.push(-1)
        group = order.length
      else
        order.push(group) if order.indexOf(group) is -1
        group = order.indexOf(group) + 1

      placeholder = data.placeholder or ''
      if placeholder
        # recursively update nested tabstops
        placeholder = tabStops.processText(placeholder, tabstopOptions)

      if placeholder then "${#{group}:#{placeholder}}" else "$#{group}"

    escape: (ch) ->
      if ch == '$' then '\\$' else ch

  tabStops.processText(value, tabstopOptions)

module.exports =
  setup: (@editor, @selectionIndex=0) ->
    buf = @editor.getBuffer()
    bufRanges = @editor.getSelectedBufferRanges()
    @_selection =
      index: 0
      saved: new Array(bufRanges.length)
      bufferRanges: bufRanges
      indexRanges: bufRanges.map (range) ->
          start: buf.characterIndexForPosition(range.start)
          end:   buf.characterIndexForPosition(range.end)

  # Executes given function for every selection
  exec: (fn) ->
    ix = @_selection.bufferRanges.length - 1
    @_selection.saved = []
    success = true
    while ix >= 0
      @_selection.index = ix
      if fn(@_selection.index) is false
        success = false
        break
      ix--

    if success and @_selection.saved.length > 1
      @_setSelectedBufferRanges(@_selection.saved)

  _setSelectedBufferRanges: (sels) ->
    filteredSels = sels.filter (s) -> !!s
    if filteredSels.length
      @editor.setSelectedBufferRanges(filteredSels)

  _saveSelection: (delta) ->
    @_selection.saved[@_selection.index] = @editor.getSelectedBufferRange()
    if delta
      i = @_selection.index
      delta = Point.fromObject([delta, 0])
      while ++i < @_selection.saved.length
        range = @_selection.saved[i]
        if range
          @_selection.saved[i] = new Range(range.start.translate(delta), range.end.translate(delta))

  selectionList: ->
    @_selection.indexRanges

  # Returns the current caret position.
  getCaretPos: ->
    @getSelectionRange().start

  # Sets the current caret position.
  setCaretPos: (pos) ->
    @createSelection(pos)

  # Fetches the character indexes of the selected text.
  # Returns an {Object} with `start` and `end` properties.
  getSelectionRange: ->
    @_selection.indexRanges[@_selection.index]

  getSelectionBufferRange: ->
    @_selection.bufferRanges[@_selection.index]

  # Creates a selection from the `start` to `end` character indexes.
  #
  # If `end` is ommited, this method should place a caret at the `start` index.
  #
  # start - A {Number} representing the starting character index
  # end - A {Number} representing the ending character index
  createSelection: (start, end=start) ->
    sels = @_selection.bufferRanges
    buf = @editor.getBuffer()
    sels[@_selection.index] = new Range(buf.positionForCharacterIndex(start), buf.positionForCharacterIndex(end))
    @_setSelectedBufferRanges(sels)

  # Returns the currently selected text.
  getSelection: ->
    @editor.getTextInBufferRange(@getSelectionBufferRange())

  # Fetches the current line's start and end indexes.
  #
  # Returns an {Object} with `start` and `end` properties
  getCurrentLineRange: ->
    sel = @getSelectionBufferRange()
    row = sel.getRows()[0]
    lineLength = @editor.lineTextForBufferRow(row).length
    index = @editor.getBuffer().characterIndexForPosition({row: row, column: 0})
    return {
      start: index
      end: index + lineLength
    }

  # Returns the current line.
  getCurrentLine: ->
    sel = @getSelectionBufferRange()
    row = sel.getRows()[0]
    return @editor.lineForBufferRow(row)

  # Returns the editor content.
  getContent: ->
    return @editor.getText()

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
    unless end?
      end = unless start? then @getContent().length else start
    start = 0 unless start?

    value = normalize(value, @editor)
    buf = @editor.getBuffer()
    changeRange = new Range(
      Point.fromObject(buf.positionForCharacterIndex(start)),
      Point.fromObject(buf.positionForCharacterIndex(end))
    )

    oldValue = @editor.getTextInBufferRange(changeRange)
    buf.setTextInRange(changeRange, '')
    # Before inserting snippet we have to reset all available selections
    # to insert snippent right in required place. Otherwise snippet
    # will be inserted for each selection in editor

    # Right after that we should save first available selection as buffer range
    caret = buf.positionForCharacterIndex(start)
    @editor.setSelectedBufferRange(new Range(caret, caret))
    insertSnippet preprocessSnippet(value), @editor
    @_saveSelection(utils.splitByLines(value).length - utils.splitByLines(oldValue).length)
    value

  getGrammar: ->
    @editor.getGrammar().name.toLowerCase()

  # Returns the editor's syntax mode.
  getSyntax: ->
    syntax = @getGrammar()
    if syntax is 'html'
      # HTML can contain embedded syntaxes
      embedded = @getCurrentScope().filter((s) -> /\.embedded\./.test s).pop()
      if embedded
        m = embedded.match /source\.(.+?)\.embedded/
        syntax = m[1] if m

    return syntax

  getCurrentScope: ->
    range = @_selection.bufferRanges[@_selection.index]
    @editor.scopeDescriptorForBufferPosition(range.start).getScopesArray()

  # Returns the current output profile name
  #
  # See emmet.setupProfile for more information.
  getProfileName: ->
    'html'

  # Returns the current editor's file path
  getFilePath: ->
    # is there a better way to get this?
    @editor.buffer.file.path
