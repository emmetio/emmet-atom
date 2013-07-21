Emmet = require 'emmet/lib/emmet'
RootView = require 'root-view'
Buffer = require 'text-buffer'
Editor = require 'editor'

describe "Emmet", ->
  [buffer, editor, editSession] = []
  keymap = null

  beforeEach ->
    window.rootView = new RootView
    rootView.open('sample.js')

    editor = rootView.getActiveView()
    editSession = rootView.getActivePaneItem()
    buffer = editor.getBuffer()

    atom.activatePackage("emmet")

    rootView.simulateDomAttachment()
    rootView.enableKeymap()

  describe "emmet:expand-abbreviation", ->
    htmlSolution = null

    beforeEach ->
      buffer.setText('')
      editor.insertText "#header>ul#nav>li*4>a"
      htmlSolution = '<div id="header">\n  <ul id="nav">\n    <li><a href=""></a></li>\n    <li><a href=""></a></li>\n    <li><a href=""></a></li>\n    <li><a href=""></a></li>\n  </ul>\n</div>'

    it "expands HTML abbreviations via commands", ->
      editor.trigger "emmet:expand-abbreviation"
      expect(editor.getText()).toBe htmlSolution

    it "expands HTML abbreviations via keybindings", ->
      editor.trigger keydownEvent('e', shiftKey: true, metaKey: true, target: editor[0])
      expect(editor.getText()).toBe htmlSolution
