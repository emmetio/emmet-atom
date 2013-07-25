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

    describe "for go-to match-pair", ->
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

  describe "emmet:edit-point", ->
    beforeEach ->
      rootView.open(Path.join(__dirname, './fixtures/edit-points/edit-points.html'))
      editor = rootView.getActiveView()
      editSession = rootView.getActivePaneItem()

    describe "for next-edit-point", ->
      beforeEach ->
        editSession.setCursorBufferPosition([0, 0])

      it "finds the next-edit-point via commands", ->
        editor.trigger "emmet:next-edit-point"
        expect(editor.getCursor().getBufferPosition()).toEqual [1, 8]
        editor.trigger "emmet:next-edit-point"
        expect(editor.getCursor().getBufferPosition()).toEqual [1, 17]
        editor.trigger "emmet:next-edit-point"
        expect(editor.getCursor().getBufferPosition()).toEqual [1, 19]

      it "finds the next-edit-point via keybindings", ->
        editor.trigger keydownEvent('right', ctrlKey: true, altKey:true, target: editor[0])
        expect(editor.getCursor().getBufferPosition()).toEqual [1, 8]
        editor.trigger keydownEvent('right', ctrlKey: true, altKey:true, target: editor[0])
        expect(editor.getCursor().getBufferPosition()).toEqual [1, 17]
        editor.trigger keydownEvent('right', ctrlKey: true, altKey:true, target: editor[0])
        expect(editor.getCursor().getBufferPosition()).toEqual [1, 19]

    describe "for prev-edit-point", ->
      beforeEach ->
        editSession.setCursorBufferPosition([9, 15])

      it "finds the prev-edit-point via commands", ->
        editor.trigger "emmet:prev-edit-point"
        expect(editor.getCursor().getBufferPosition()).toEqual [2, 23]
        editor.trigger "emmet:prev-edit-point"
        expect(editor.getCursor().getBufferPosition()).toEqual [2, 19]
        editor.trigger "emmet:prev-edit-point"
        expect(editor.getCursor().getBufferPosition()).toEqual [2, 17]

      it "finds the prev-edit-point via keybindings", ->
        editor.trigger keydownEvent('left', ctrlKey: true, altKey:true, target: editor[0])
        expect(editor.getCursor().getBufferPosition()).toEqual [2, 23]
        editor.trigger keydownEvent('left', ctrlKey: true, altKey:true, target: editor[0])
        expect(editor.getCursor().getBufferPosition()).toEqual [2, 19]
        editor.trigger keydownEvent('left', ctrlKey: true, altKey:true, target: editor[0])
        expect(editor.getCursor().getBufferPosition()).toEqual [2, 17]

  describe "emmet:split-join-tag", ->
    beforeEach ->
      rootView.open(Path.join(__dirname, './fixtures/split-join-tag/split-join-tag.html'))
      editor = rootView.getActiveView()
      editSession = rootView.getActivePaneItem()

    describe "for split-join-tag", ->
      beforeEach ->
        editSession.setCursorBufferPosition([1, 10])

      it "calls split-join-tag via commands", ->
        editor.trigger "emmet:split-join-tag"
        expect(editor.lineForBufferRow(0)).toBe "<example />"
        editor.trigger "emmet:split-join-tag"
        expect(editor.lineForBufferRow(0)).toBe "<example></example>"
        editor.trigger "emmet:split-join-tag"
        expect(editor.lineForBufferRow(0)).toBe "<example />"

      it "calls split-join-tag via keybindings", ->
       editor.trigger keydownEvent('j', shiftKey: true, metaKey: true, target: editor[0])
       expect(editor.lineForBufferRow(0)).toBe "<example />"
       editor.trigger keydownEvent('j', shiftKey: true, metaKey: true, target: editor[0])
       expect(editor.lineForBufferRow(0)).toBe "<example></example>"
       editor.trigger keydownEvent('j', shiftKey: true, metaKey: true, target: editor[0])
       expect(editor.lineForBufferRow(0)).toBe "<example />"

  fdescribe "emmet:remove-tag", ->
    onceRemoved = twiceRemoved = null

    beforeEach ->
      rootView.open(Path.join(__dirname, './fixtures/remove-tag/before/remove-tag.html'))
      editor = rootView.getActiveView()
      editSession = rootView.getActivePaneItem()

      onceRemoved = Fs.readFileSync(Path.join(__dirname, './fixtures/remove-tag/after/remove-tag-once.html'), "utf8")
      twiceRemoved = Fs.readFileSync(Path.join(__dirname, './fixtures/remove-tag/after/remove-tag-twice.html'), "utf8")

    describe "for remove-tag", ->
      beforeEach ->
        editSession.setCursorBufferPosition([1, 10])

      it "calls remove-tag via commands", ->
        editor.trigger "emmet:remove-tag"
        expect(editor.getText()).toBe onceRemoved
        editor.trigger "emmet:remove-tag"
        expect(editor.getText()).toBe twiceRemoved

      it "calls remove-tag via keybindings", ->
       editor.trigger keydownEvent('k', shiftKey: true, metaKey: true, target: editor[0])
       expect(editor.getText()).toBe onceRemoved
       editor.trigger keydownEvent('k', shiftKey: true, metaKey: true, target: editor[0])
       expect(editor.getText()).toBe twiceRemoved
