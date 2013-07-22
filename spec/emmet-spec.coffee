RootView = require 'root-view'
Buffer = require 'text-buffer'
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

  fdescribe "emmet:expand-abbreviation", ->
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
