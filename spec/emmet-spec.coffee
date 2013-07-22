RootView = require 'root-view'
Buffer = require 'text-buffer'
Editor = require 'editor'

describe "Emmet", ->
  [buffer, editor, editSession, htmlSolution, cssSolution] = []

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
    describe "for HTML", ->
      beforeEach ->
        rootView.open('foo.html.erb')
        editor = rootView.getActiveView()
        editSession = rootView.getActivePaneItem()
        editor.setText "#header>ul#nav>li*4>a[href]"

        htmlSolution = '<div id="header">\n  <ul id="nav">\n    <li><a href=""></a></li>\n    <li><a href=""></a></li>\n    <li><a href=""></a></li>\n    <li><a href=""></a></li>\n  </ul>\n</div>'

      it "expands HTML abbreviations via commands", ->
        editor.trigger "emmet:expand-abbreviation"
        expect(editor.getText()).toBe htmlSolution

      it "expands HTML abbreviations via keybindings", ->
        editor.trigger keydownEvent('e', shiftKey: true, metaKey: true, target: editor[0])
        expect(editor.getText()).toBe htmlSolution

    describe "for CSS", ->
      beforeEach ->
        rootView.open('css.css')
        editor = rootView.getActiveView()
        editSession = rootView.getActivePaneItem()
        buffer = editor.getBuffer()
        buffer.setText('')
        editor.setText "m10"

        cssSolution = "margin: 10px;"

      it "expands CSS abbreviations via commands", ->
        editor.trigger "emmet:expand-abbreviation"
        expect(editor.getText()).toBe cssSolution

      it "expands CSS abbreviations via keybindings", ->
        editor.trigger keydownEvent('e', shiftKey: true, metaKey: true, target: editor[0])
        expect(editor.getText()).toBe cssSolution
