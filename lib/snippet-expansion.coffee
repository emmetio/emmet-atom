path = require 'path'

snippetsPath = atom.packages.resolvePackagePath('snippets')
SnippetExpansion = require path.join(snippetsPath, 'lib/snippet-expansion')

module.exports = 
class EmmetSnippetExpansion extends SnippetExpansion
  constructor: (@snippet, @editor) ->
    # Since Emmet expands not words but complex abbreviations,
    # override `SnippetExpansion` constuctor and skip prefix selection
    startPosition = @editor.getCursorBufferPosition()
    [newRange] = @editor.insertText(snippet.body, autoIndent: false)
    if snippet.tabStops.length > 0
      @subscribe @editor, 'cursor-moved.snippet-expansion', (e) => @cursorMoved(e)
      @placeTabStopMarkers(startPosition, snippet.tabStops)
      @editor.snippetExpansion = this
      @editor.normalizeTabsInBufferRange(newRange)
    @indentSubsequentLines(startPosition.row, snippet) if snippet.lineCount > 1