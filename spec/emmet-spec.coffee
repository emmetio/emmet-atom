RootView = require 'root-view'
Editor = require 'editor'
Path = require 'path'
Fs = require 'fs'

describe "Emmet", ->
  [buffer, editor, editSession] = []

  beforeEach ->
    window.rootView = new RootView

    atom.activatePackage("emmet")
    atom.activatePackage('css-tmbundle', sync: true)
    atom.activatePackage('html-tmbundle', sync: true)

    rootView.simulateDomAttachment()
    rootView.enableKeymap()

  afterEach ->
    editSession.destroy()

  describe "emmet:expand-abbreviation", ->
    expansion = null

    describe "for HTML", ->
      beforeEach ->
        rootView.open(Path.join(__dirname, './fixtures/abbreviation/before/html-abbrv.html'))
        editor = rootView.getActiveView()
        editSession = rootView.getActivePaneItem()
        editSession.moveCursorToEndOfLine()

        expansion = Fs.readFileSync(Path.join(__dirname, './fixtures/abbreviation/after/html-abbrv.html'), "utf8")

      it "expands HTML abbreviations via commands", ->
        editor.trigger "emmet:expand-abbreviation"
        expect(editor.getText()).toBe expansion

      it "expands HTML abbreviations via keybindings", ->
        editor.trigger keydownEvent('e', shiftKey: true, metaKey: true, target: editor[0])
        expect(editor.getText()).toBe expansion

    describe "for CSS", ->
      beforeEach ->
        rootView.open(Path.join(__dirname, './fixtures/abbreviation/before/css-abbrv.css'))
        editor = rootView.getActiveView()
        editSession = rootView.getActivePaneItem()
        editSession.moveCursorToEndOfLine()

        expansion = Fs.readFileSync(Path.join(__dirname, './fixtures/abbreviation/after/css-abbrv.css'), "utf8")

      it "expands CSS abbreviations via commands", ->
        editor.trigger "emmet:expand-abbreviation"
        expect(editor.getText()).toBe expansion

      it "expands CSS abbreviations via keybindings", ->
        editor.trigger keydownEvent('e', shiftKey: true, metaKey: true, target: editor[0])
        expect(editor.getText()).toBe expansion

  describe "emmet:match-pair", ->
    beforeEach ->
      rootView.open(Path.join(__dirname, './fixtures/match-pair/sample.html'))
      editor = rootView.getActiveView()
      editSession = rootView.getActivePaneItem()

    describe "for match-pair-outward", ->
      beforeEach ->
        editSession.setCursorBufferPosition([3, 23])

      it "matches pairs outwards via commands", ->
        expect(editor.getSelection().getBufferRange()).toEqual [[3, 23], [3, 23]]
        editor.trigger "emmet:match-pair-outward"
        expect(editor.getSelection().getBufferRange()).toEqual [[3, 11], [3, 38]]
        editor.trigger "emmet:match-pair-outward"
        expect(editor.getSelection().getBufferRange()).toEqual [[3, 8], [3, 42]]
        editor.trigger "emmet:match-pair-outward"
        expect(editor.getSelection().getBufferRange()).toEqual [[1, 29], [4, 4]]

      it "matches pairs outwards via keybindings", ->
        expect(editor.getSelection().getBufferRange()).toEqual [[3, 23], [3, 23]]
        editor.trigger keydownEvent('d', ctrlKey: true, target: editor[0])
        expect(editor.getSelection().getBufferRange()).toEqual [[3, 11], [3, 38]]
        editor.trigger keydownEvent('d', ctrlKey: true, target: editor[0])
        expect(editor.getSelection().getBufferRange()).toEqual [[3, 8], [3, 42]]
        editor.trigger keydownEvent('d', ctrlKey: true, target: editor[0])
        expect(editor.getSelection().getBufferRange()).toEqual [[1, 29], [4, 4]]

    describe "for match-pair-inward", ->
      beforeEach ->
        editSession.setCursorBufferPosition([3, 23])

      it "matches pairs inwards via commands", ->
        editSession.getSelection().setBufferRange([[1, 29], [4, 4]])
        editor.trigger "emmet:match-pair-inward"
        expect(editor.getSelection().getBufferRange()).toEqual [[2, 8], [2, 33]]
        editor.trigger keydownEvent('d', altKey: true, target: editor[0])
        expect(editor.getSelection().getBufferRange()).toEqual [[2, 12], [2, 28]]

    fdescribe "for go-to match-pair", ->
      it "goes to the match-pair via commands", ->
        editSession.setCursorBufferPosition([4, 10])
        editor.trigger "emmet:matching-pair"
        expect(editor.getCursor().getBufferPosition()).toEqual [1, 4]

        editSession.setCursorBufferPosition([5, 5])
        editor.trigger "emmet:matching-pair"
        expect(editor.getCursor().getBufferPosition()).toEqual [0, 0]

      it "goes to the match-pair via keybindings", ->
        editSession.setCursorBufferPosition([4, 10])
        editor.trigger keydownEvent('j', ctrlKey: true, altKey: true, target: editor[0])
        expect(editor.getCursor().getBufferPosition()).toEqual [1, 4]

        editSession.setCursorBufferPosition([5, 5])
        editor.trigger keydownEvent('j', ctrlKey: true, altKey: true, target: editor[0])
        expect(editor.getCursor().getBufferPosition()).toEqual [0, 0]
