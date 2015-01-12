Path = require "path"
Fs = require "fs"

readFile = (path) ->
  Fs.readFileSync(Path.join(__dirname, "./fixtures/", path), "utf8")

describe "Emmet", ->
  [editor, editorElement] = []

  console.log atom.keymaps.onDidMatchBinding (event) ->
    console.log 'Matched keybinding', event


  simulateTabKeyEvent = () ->
    event = keydownEvent("tab", {target: editorElement})
    atom.keymaps.handleKeyboardEvent(event.originalEvent)

  beforeEach ->
    waitsForPromise ->
      atom.workspace.open("tabbing.html")

    waitsForPromise ->
      atom.packages.activatePackage("emmet")

    waitsForPromise ->
      atom.packages.activatePackage("snippets") # to intentionally disrupt tab expansion

    waitsForPromise ->
      atom.packages.activatePackage("language-css", sync: true)

    waitsForPromise ->
      atom.packages.activatePackage("language-sass", sync: true)

    waitsForPromise ->
      atom.packages.activatePackage("language-php", sync: true)

    waitsForPromise ->
      atom.packages.activatePackage("language-html", sync: true)

    runs ->
      # make sure emitter is initiated to properly deactivate package
      atom.packages.getLoadedPackage('snippets')?.mainModule?.getEmitter()
      editor = atom.workspace.getActiveTextEditor()
      editorElement = atom.views.getView(editor)

  describe "tabbing", ->
    beforeEach ->
      atom.workspace.open('tabbing.html')
      editor.setCursorScreenPosition([1, 4])

    it "moves the cursor along", ->
      simulateTabKeyEvent()
      cursorPos = editor.getCursorScreenPosition()
      expect(cursorPos.column).toBe 6

  describe "emmet:expand-abbreviation", ->
    expansion = null

    describe "for normal HTML", ->
      beforeEach ->
        editor.setText readFile "abbreviation/before/html-abbrv.html"
        editor.moveToEndOfLine()

        expansion = readFile "abbreviation/after/html-abbrv.html"

      it "expands HTML abbreviations via commands", ->
        atom.commands.dispatch editorElement, "emmet:expand-abbreviation"
        expect(editor.getText()).toBe expansion

      it "expands HTML abbreviations via keybindings", ->
        event = keydownEvent('e', shiftKey: true, metaKey: true, target: editorElement)
        atom.keymaps.handleKeyboardEvent(event.originalEvent)
        expect(editor.getText()).toBe expansion

      it "expands HTML abbreviations via Tab", ->
        console.log atom.keymaps.findKeyBindings keystrokes: 'tab'
        simulateTabKeyEvent()
        expect(editor.getText()).toBe expansion

  #   describe "for HTML with attributes", ->
  #     beforeEach ->
  #       workspaceView.openSync(Path.join(__dirname, './fixtures/abbreviation/before/anchor-class-expand.html'))
  #       editorView = workspaceView.getActiveView()
  #       editor = editorView.getEditor()
  #       editSession = workspaceView.getActivePaneItem()
  #       editSession.moveCursorToEndOfLine()

  #       expansion = Fs.readFileSync(Path.join(__dirname, './fixtures/abbreviation/after/anchor-class-expand.html'), "utf8")

  #     it "expands HTML abbreviations via commands", ->
  #       editorView.trigger "emmet:expand-abbreviation"
  #       expect(editorView.getText()).toBe expansion
  #       cursorPos = editor.getCursorScreenPosition()
  #       expect(cursorPos.column).toBe 9

  #     it "expands HTML abbreviations via keybindings", ->
  #       editorView.trigger keydownEvent('e', shiftKey: true, metaKey: true, target: editor[0])
  #       expect(editor.getText()).toBe expansion
  #       cursorPos = editor.getCursorScreenPosition()
  #       expect(cursorPos.column).toBe 9

  #     it "expands HTML abbreviations via Tab", ->
  #       editorView.trigger keydownEvent('tab', target: editor[0])
  #       expect(editor.getText()).toBe expansion
  #       cursorPos = editor.getCursorScreenPosition()
  #       expect(cursorPos.column).toBe 9

  #   # headers seem to be a special case: http://git.io/7XeBKQ
  #   describe "for headers in HTML", ->
  #     beforeEach ->
  #       workspaceView.openSync(Path.join(__dirname, './fixtures/abbreviation/before/header-expand.html'))
  #       editorView = workspaceView.getActiveView()
  #       editor = editorView.getEditor()
  #       editSession = workspaceView.getActivePaneItem()
  #       editSession.moveCursorToEndOfLine()

  #       expansion = Fs.readFileSync(Path.join(__dirname, './fixtures/abbreviation/after/header-expand.html'), "utf8")

  #     it "expands HTML abbreviations via commands", ->
  #       editorView.trigger "emmet:expand-abbreviation"
  #       expect(editorView.getText()).toBe expansion

  #     it "expands HTML abbreviations via keybindings", ->
  #       editorView.trigger keydownEvent('e', shiftKey: true, metaKey: true, target: editor[0])
  #       expect(editorView.getText()).toBe expansion

  #     it "expands HTML abbreviations via Tab", ->
  #       editorView.trigger keydownEvent('tab', target: editor[0])
  #       expect(editorView.getText()).toBe expansion

  #   describe "for CSS", ->
  #     beforeEach ->
  #       workspaceView.openSync(Path.join(__dirname, './fixtures/abbreviation/before/css-abbrv.css'))
  #       editorView = workspaceView.getActiveView()
  #       editor = editorView.getEditor()
  #       editSession = workspaceView.getActivePaneItem()
  #       editSession.moveCursorToEndOfLine()

  #       expansion = Fs.readFileSync(Path.join(__dirname, './fixtures/abbreviation/after/css-abbrv.css'), "utf8")

  #     it "expands CSS abbreviations via commands", ->
  #       editorView.trigger "emmet:expand-abbreviation"
  #       expect(editor.getText()).toBe expansion

  #     it "expands CSS abbreviations via keybindings", ->
  #       editorView.trigger keydownEvent('e', shiftKey: true, metaKey: true, target: editor[0])
  #       expect(editor.getText()).toBe expansion

  #     it "expands CSS abbreviations via tab", ->
  #       editorView.trigger keydownEvent('tab', target: editor[0])
  #       expect(editor.getText()).toBe expansion

  #   describe "for PHP", ->
  #     describe "for PHP with HTML", ->
  #       beforeEach ->
  #         workspaceView.openSync(Path.join(__dirname, './fixtures/abbreviation/before/php-in-html.php'))
  #         editorView = workspaceView.getActiveView()
  #         editor = editorView.getEditor()
  #         editSession = workspaceView.getActivePaneItem()
  #         editSession.setCursorBufferPosition([6, 5])

  #         expansion = Fs.readFileSync(Path.join(__dirname, './fixtures/abbreviation/after/php-in-html.php'), "utf8")

  #       it "expands abbreviations via commands", ->
  #         editorView.trigger "emmet:expand-abbreviation"
  #         expect(editor.getText()).toBe expansion

  #       it "expands abbreviations via keybindings", ->
  #         editorView.trigger keydownEvent('e', shiftKey: true, metaKey: true, target: editor[0])
  #         expect(editor.getText()).toBe expansion

  #       it "expands abbreviations via tab", ->
  #         editorView.trigger keydownEvent('tab', target: editor[0])
  #         expect(editor.getText()).toBe expansion

  #     # fdescribe "for vanilla PHP", ->
  #     #   beforeEach ->
  #     #     workspaceView.openSync(Path.join(__dirname, './fixtures/abbreviation/before/vanilla-php.php'))
  #     #     editorView = workspaceView.getActiveView()
  #     #     editor = editorView.getEditor()
  #     #     editSession = workspaceView.getActivePaneItem()
  #     #     editSession.setCursorBufferPosition([1, 3])
  #     #
  #     #     expansion = Fs.readFileSync(Path.join(__dirname, './fixtures/abbreviation/after/vanilla-php.php'), "utf8")
  #     #
  #     #   it "expands abbreviations via commands", ->
  #     #     editorView.trigger "emmet:expand-abbreviation"
  #     #     expect(editor.getText()).toBe expansion
  #     #
  #     #   it "expands abbreviations via keybindings", ->
  #     #     editorView.trigger keydownEvent('e', shiftKey: true, metaKey: true, target: editor[0])
  #     #     expect(editor.getText()).toBe expansion
  #     #
  #     #   it "expands abbreviations via tab", ->
  #     #     editorView.trigger keydownEvent('tab', target: editor[0])
  #     #     expect(editor.getText()).toBe expansion

  #   describe "for SASS", ->
  #     beforeEach ->
  #       workspaceView.openSync(Path.join(__dirname, './fixtures/abbreviation/before/sass-test.sass'))
  #       editorView = workspaceView.getActiveView()
  #       editor = editorView.getEditor()
  #       editSession = workspaceView.getActivePaneItem()
  #       editSession.moveCursorToEndOfLine()

  #       expansion = Fs.readFileSync(Path.join(__dirname, './fixtures/abbreviation/after/sass-test.sass'), "utf8")

  #     it "expands abbreviations via commands", ->
  #       editorView.trigger "emmet:expand-abbreviation"
  #       expect(editor.getText()).toBe expansion

  #     it "expands abbreviations via keybindings", ->
  #       editorView.trigger keydownEvent('e', shiftKey: true, metaKey: true, target: editor[0])
  #       expect(editor.getText()).toBe expansion

  #     it "expands abbreviations via tab", ->
  #       editorView.trigger keydownEvent('tab', target: editor[0])
  #       expect(editor.getText()).toBe expansion

  #   describe "for multiple cursors", ->
  #     beforeEach ->
  #       workspaceView.openSync(Path.join(__dirname, './fixtures/abbreviation/before/multi-line.html'))
  #       editorView = workspaceView.getActiveView()
  #       editor = editorView.getEditor()
  #       editSession = workspaceView.getActivePaneItem()

  #       editor.addCursorAtBufferPosition([0, 9])
  #       editor.addCursorAtBufferPosition([1, 9])
  #       editor.addCursorAtBufferPosition([2, 9])

  #       expansion = Fs.readFileSync(Path.join(__dirname, './fixtures/abbreviation/after/multi-line.html'), "utf8")

  #     it "expands HTML abbreviations via commands", ->
  #       editorView.trigger "emmet:expand-abbreviation"
  #       expect(editorView.getText()).toBe expansion

  #     # it "expands HTML abbreviations via keybindings", ->
  #     #   editorView.trigger keydownEvent('e', shiftKey: true, metaKey: true, target: editor[0])
  #     #   expect(editor.getText()).toBe expansion
  #     #
  #     # it "expands HTML abbreviations via Tab", ->
  #     #   editorView.trigger keydownEvent('tab', target: editor[0])
  #     #   expect(editor.getText()).toBe expansion

  # describe "emmet:balance", ->
  #   beforeEach ->
  #     workspaceView.openSync(Path.join(__dirname, './fixtures/balance/sample.html'))
  #     editorView = workspaceView.getActiveView()
  #     editor = editorView.getEditor()
  #     editSession = workspaceView.getActivePaneItem()

  #   describe "for balance-outward", ->
  #     beforeEach ->
  #       editSession.setCursorBufferPosition([3, 23])

  #     it "matches pairs outwards via commands", ->
  #       expect(editor.getSelection().getBufferRange()).toEqual [[3, 23], [3, 23]]
  #       editorView.trigger "emmet:balance-outward"
  #       expect(editor.getSelection().getBufferRange()).toEqual [[3, 11], [3, 38]]
  #       editorView.trigger "emmet:balance-outward"
  #       expect(editor.getSelection().getBufferRange()).toEqual [[3, 8], [3, 42]]
  #       editorView.trigger "emmet:balance-outward"
  #       expect(editor.getSelection().getBufferRange()).toEqual [[1, 29], [4, 4]]

  #     it "matches pairs outwards via keybindings", ->
  #       expect(editor.getSelection().getBufferRange()).toEqual [[3, 23], [3, 23]]
  #       editorView.trigger keydownEvent('d', ctrlKey: true, target: editor[0])
  #       expect(editor.getSelection().getBufferRange()).toEqual [[3, 11], [3, 38]]
  #       editorView.trigger keydownEvent('d', ctrlKey: true, target: editor[0])
  #       expect(editor.getSelection().getBufferRange()).toEqual [[3, 8], [3, 42]]
  #       editorView.trigger keydownEvent('d', ctrlKey: true, target: editor[0])
  #       expect(editor.getSelection().getBufferRange()).toEqual [[1, 29], [4, 4]]

  #   describe "for balance-inward", ->
  #     beforeEach ->
  #       editSession.setCursorBufferPosition([1, 4])

  #     it "matches pairs inwards via commands", ->
  #       editorView.trigger "emmet:balance-inward"
  #       expect(editor.getSelection().getBufferRange()).toEqual [[0, 15], [5, 0]]
  #       editorView.trigger "emmet:balance-inward"
  #       expect(editor.getSelection().getBufferRange()).toEqual [[1, 4], [4, 14]]
  #       editorView.trigger "emmet:balance-inward"
  #       expect(editor.getSelection().getBufferRange()).toEqual [[1, 29], [4, 4]]
  #       editorView.trigger "emmet:balance-inward"
  #       expect(editor.getSelection().getBufferRange()).toEqual [[2, 8], [2, 33]]

  #     it "matches pairs inwards via keybindings", ->
  #       editorView.trigger keydownEvent('d', altKey: true, target: editor[0])
  #       expect(editor.getSelection().getBufferRange()).toEqual [[0, 15], [5, 0]]
  #       editorView.trigger keydownEvent('d', altKey: true, target: editor[0])
  #       expect(editor.getSelection().getBufferRange()).toEqual [[1, 4], [4, 14]]
  #       editorView.trigger keydownEvent('d', altKey: true, target: editor[0])
  #       expect(editor.getSelection().getBufferRange()).toEqual [[1, 29], [4, 4]]
  #       editorView.trigger keydownEvent('d', altKey: true, target: editor[0])
  #       expect(editor.getSelection().getBufferRange()).toEqual [[2, 8], [2, 33]]

  #   describe "for go-to match-pair", ->
  #     it "goes to the match-pair via commands", ->
  #       editSession.setCursorBufferPosition([4, 10])
  #       editorView.trigger "emmet:matching-pair"
  #       expect(editor.getCursor().getBufferPosition()).toEqual [1, 4]

  #       editSession.setCursorBufferPosition([5, 5])
  #       editorView.trigger "emmet:matching-pair"
  #       expect(editor.getCursor().getBufferPosition()).toEqual [0, 0]

  #     it "goes to the match-pair via keybindings", ->
  #       editSession.setCursorBufferPosition([4, 10])
  #       editorView.trigger keydownEvent('j', ctrlKey: true, altKey: true, target: editor[0])
  #       expect(editor.getCursor().getBufferPosition()).toEqual [1, 4]

  #       editSession.setCursorBufferPosition([5, 5])
  #       editorView.trigger keydownEvent('j', ctrlKey: true, altKey: true, target: editor[0])
  #       expect(editor.getCursor().getBufferPosition()).toEqual [0, 0]

  # describe "emmet:edit-point", ->
  #   beforeEach ->
  #     workspaceView.openSync(Path.join(__dirname, './fixtures/edit-points/edit-points.html'))
  #     editorView = workspaceView.getActiveView()
  #     editor = editorView.getEditor()
  #     editSession = workspaceView.getActivePaneItem()

  #   describe "for next-edit-point", ->
  #     beforeEach ->
  #       editSession.setCursorBufferPosition([0, 0])

  #     it "finds the next-edit-point via commands", ->
  #       editorView.trigger "emmet:next-edit-point"
  #       expect(editor.getCursor().getBufferPosition()).toEqual [1, 8]
  #       editorView.trigger "emmet:next-edit-point"
  #       expect(editor.getCursor().getBufferPosition()).toEqual [1, 17]
  #       editorView.trigger "emmet:next-edit-point"
  #       expect(editor.getCursor().getBufferPosition()).toEqual [1, 19]

  #     it "finds the next-edit-point via keybindings", ->
  #       editorView.trigger keydownEvent('.', ctrlKey: true, altKey:true, target: editor[0])
  #       expect(editor.getCursor().getBufferPosition()).toEqual [1, 8]
  #       editorView.trigger keydownEvent('.', ctrlKey: true, altKey:true, target: editor[0])
  #       expect(editor.getCursor().getBufferPosition()).toEqual [1, 17]
  #       editorView.trigger keydownEvent('.', ctrlKey: true, altKey:true, target: editor[0])
  #       expect(editor.getCursor().getBufferPosition()).toEqual [1, 19]

  #   describe "for prev-edit-point", ->
  #     beforeEach ->
  #       editSession.setCursorBufferPosition([9, 15])

  #     it "finds the prev-edit-point via commands", ->
  #       editorView.trigger "emmet:prev-edit-point"
  #       expect(editor.getCursor().getBufferPosition()).toEqual [2, 23]
  #       editorView.trigger "emmet:prev-edit-point"
  #       expect(editor.getCursor().getBufferPosition()).toEqual [2, 19]
  #       editorView.trigger "emmet:prev-edit-point"
  #       expect(editor.getCursor().getBufferPosition()).toEqual [2, 17]

  #     it "finds the prev-edit-point via keybindings", ->
  #       editorView.trigger keydownEvent(',', ctrlKey: true, altKey:true, target: editor[0])
  #       expect(editor.getCursor().getBufferPosition()).toEqual [2, 23]
  #       editorView.trigger keydownEvent(',', ctrlKey: true, altKey:true, target: editor[0])
  #       expect(editor.getCursor().getBufferPosition()).toEqual [2, 19]
  #       editorView.trigger keydownEvent(',', ctrlKey: true, altKey:true, target: editor[0])
  #       expect(editor.getCursor().getBufferPosition()).toEqual [2, 17]

  # describe "emmet:split-join-tag", ->
  #   beforeEach ->
  #     workspaceView.openSync(Path.join(__dirname, './fixtures/split-join-tag/split-join-tag.html'))
  #     editorView = workspaceView.getActiveView()
  #     editor = editorView.getEditor()
  #     editSession = workspaceView.getActivePaneItem()

  #   describe "for split-join-tag", ->
  #     beforeEach ->
  #       editSession.setCursorBufferPosition([1, 10])

  #     it "calls split-join-tag via commands", ->
  #       editorView.trigger "emmet:split-join-tag"
  #       expect(editor.lineForBufferRow(0)).toBe "<example />"
  #       editorView.trigger "emmet:split-join-tag"
  #       expect(editor.lineForBufferRow(0)).toBe "<example></example>"
  #       editorView.trigger "emmet:split-join-tag"
  #       expect(editor.lineForBufferRow(0)).toBe "<example />"

  #     it "calls split-join-tag via keybindings", ->
  #      editorView.trigger keydownEvent('j', shiftKey: true, metaKey: true, target: editor[0])
  #      expect(editor.lineForBufferRow(0)).toBe "<example />"
  #      editorView.trigger keydownEvent('j', shiftKey: true, metaKey: true, target: editor[0])
  #      expect(editor.lineForBufferRow(0)).toBe "<example></example>"
  #      editorView.trigger keydownEvent('j', shiftKey: true, metaKey: true, target: editor[0])
  #      expect(editor.lineForBufferRow(0)).toBe "<example />"

  # describe "emmet:remove-tag", ->
  #   onceRemoved = twiceRemoved = null

  #   beforeEach ->
  #     workspaceView.openSync(Path.join(__dirname, './fixtures/remove-tag/before/remove-tag.html'))
  #     editorView = workspaceView.getActiveView()
  #     editor = editorView.getEditor()
  #     editSession = workspaceView.getActivePaneItem()

  #     onceRemoved = Fs.readFileSync(Path.join(__dirname, './fixtures/remove-tag/after/remove-tag-once.html'), "utf8")
  #     twiceRemoved = Fs.readFileSync(Path.join(__dirname, './fixtures/remove-tag/after/remove-tag-twice.html'), "utf8")

  #     editSession.setCursorBufferPosition([1, 10])

  #   it "calls remove-tag via commands", ->
  #     editorView.trigger "emmet:remove-tag"
  #     expect(editor.getText()).toBe onceRemoved
  #     editorView.trigger "emmet:remove-tag"
  #     expect(editor.getText()).toBe twiceRemoved

  #   it "calls remove-tag via keybindings", ->
  #    editorView.trigger keydownEvent('\'', metaKey: true, target: editor[0])
  #    expect(editor.getText()).toBe onceRemoved
  #    editorView.trigger keydownEvent('\'', metaKey: true, target: editor[0])
  #    expect(editor.getText()).toBe twiceRemoved

  # describe "emmet:evaluate-math-expression", ->
  #   beforeEach ->
  #     workspaceView.openSync(Path.join(__dirname, './fixtures/evaluate-math-expression/evaluate-math-expression.html'))
  #     editorView = workspaceView.getActiveView()
  #     editor = editorView.getEditor()
  #     editSession = workspaceView.getActivePaneItem()

  #   describe "for evaluate-math-expression", ->
  #     it "calls evaluate-math-expression via commands", ->
  #       editSession.setCursorBufferPosition([0, 3])
  #       editorView.trigger "emmet:evaluate-math-expression"
  #       editSession.setCursorBufferPosition([0, 7])
  #       editorView.trigger "emmet:evaluate-math-expression"
  #       editSession.setCursorBufferPosition([0, 12])
  #       editorView.trigger "emmet:evaluate-math-expression"
  #       expect(editor.getText()).toBe "12 3 90\n"

  #     it "calls evaluate-math-expression via keybindings", ->
  #      editSession.setCursorBufferPosition([0, 3])
  #      editorView.trigger keydownEvent('y', shiftKey: true, metaKey: true, target: editor[0])
  #      editSession.setCursorBufferPosition([0, 7])
  #      editorView.trigger keydownEvent('y', shiftKey: true, metaKey: true, target: editor[0])
  #      editSession.setCursorBufferPosition([0, 12])
  #      editorView.trigger keydownEvent('y', shiftKey: true, metaKey: true, target: editor[0])
  #      expect(editor.getText()).toBe "12 3 90\n"

  # describe "emmet increment/decrement numbers", ->
  #    beforeEach ->
  #      workspaceView.openSync(Path.join(__dirname, './fixtures/increment-decrement-numbers/increment-decrement-numbers.css'))
  #      editorView = workspaceView.getActiveView()
  #      editor = editorView.getEditor()
  #      editSession = workspaceView.getActivePaneItem()

  #    describe "for incrementing", ->
  #      describe "increment by 01", ->
  #        beforeEach ->
  #         editSession.setCursorBufferPosition([1, 18])

  #        it "increments via commands", ->
  #         editorView.trigger "emmet:increment-number-by-01"
  #         editorView.trigger "emmet:increment-number-by-01"
  #         expect(editor.lineForBufferRow(1)).toMatch(/1\.9/)
  #         editorView.trigger "emmet:increment-number-by-01"
  #         editorView.trigger "emmet:increment-number-by-01"
  #         expect(editor.lineForBufferRow(1)).toMatch(/2\.1/)

  #        it "increments via keybindings", ->
  #         editorView.trigger keydownEvent('up', ctrlKey: true, altKey: true, target: editor[0])
  #         editorView.trigger keydownEvent('up', ctrlKey: true, altKey: true, target: editor[0])
  #         expect(editor.lineForBufferRow(1)).toMatch(/1\.9/)
  #         editorView.trigger keydownEvent('up', ctrlKey: true, altKey: true, target: editor[0])
  #         editorView.trigger keydownEvent('up', ctrlKey: true, altKey: true, target: editor[0])
  #         expect(editor.lineForBufferRow(1)).toMatch(/2\.1/)

  #     describe "increment by 1", ->
  #       beforeEach ->
  #         editSession.setCursorBufferPosition([2, 13])

  #       it "increments via commands", ->
  #        editorView.trigger "emmet:increment-number-by-1"
  #        editorView.trigger "emmet:increment-number-by-1"
  #        expect(editor.lineForBufferRow(2)).toMatch(/12/)
  #        for i in [0..12] by 1
  #          editorView.trigger "emmet:increment-number-by-1"
  #        expect(editor.lineForBufferRow(2)).toMatch(/25/)

  #       it "increments via keybindings", ->
  #        editorView.trigger keydownEvent('up', ctrlKey: true, altKey: true, metaKey:true, target: editor[0])
  #        editorView.trigger keydownEvent('up', ctrlKey: true, altKey: true, metaKey:true, target: editor[0])
  #        expect(editor.lineForBufferRow(2)).toMatch(/12/)
  #        for i in [0..12] by 1
  #          editorView.trigger keydownEvent('up', ctrlKey: true, altKey: true, metaKey:true, target: editor[0])
  #        expect(editor.lineForBufferRow(2)).toMatch(/25/)

  #     describe "increment by 10", ->
  #       beforeEach ->
  #         editSession.setCursorBufferPosition([3, 12])

  #       it "increments via commands", ->
  #        editorView.trigger "emmet:increment-number-by-10"
  #        editorView.trigger "emmet:increment-number-by-10"
  #        expect(editor.lineForBufferRow(3)).toMatch(/120/)

  #       it "increments via keybindings", ->
  #        editorView.trigger keydownEvent('up', ctrlKey: true, altKey: true, metaKey: true, shiftKey: true, target: editor[0])
  #        editorView.trigger keydownEvent('up', ctrlKey: true, altKey: true, metaKey: true, shiftKey: true, target: editor[0])
  #        expect(editor.lineForBufferRow(3)).toMatch(/120/)

  #    describe "for decrementing", ->
  #      describe "decrement by 01", ->
  #        beforeEach ->
  #         editSession.setCursorBufferPosition([1, 18])

  #        it "decrements via commands", ->
  #         editorView.trigger "emmet:decrement-number-by-01"
  #         editorView.trigger "emmet:decrement-number-by-01"
  #         expect(editor.lineForBufferRow(1)).toMatch(/1\.5/)
  #         for i in [0..20] by 1
  #           editorView.trigger "emmet:decrement-number-by-01"
  #         expect(editor.lineForBufferRow(1)).toMatch(/\-0\.6/)

  #        it "decrements via keybindings", ->
  #         editorView.trigger keydownEvent('down', ctrlKey: true, altKey: true, target: editor[0])
  #         editorView.trigger keydownEvent('down', ctrlKey: true, altKey: true, target: editor[0])
  #         expect(editor.lineForBufferRow(1)).toMatch(/1\.5/)
  #         for i in [0..20] by 1
  #           editorView.trigger keydownEvent('down', ctrlKey: true, altKey: true, target: editor[0])
  #         expect(editor.lineForBufferRow(1)).toMatch(/\-0\.6/)

  #     describe "decrement by 1", ->
  #       beforeEach ->
  #         editSession.setCursorBufferPosition([2, 13])

  #       it "decrements via commands", ->
  #        editorView.trigger "emmet:decrement-number-by-1"
  #        editorView.trigger "emmet:decrement-number-by-1"
  #        expect(editor.lineForBufferRow(2)).toMatch(/8/)
  #        for i in [0..12] by 1
  #          editorView.trigger "emmet:decrement-number-by-1"
  #        expect(editor.lineForBufferRow(2)).toMatch(/\-5/)

  #       it "decrements via keybindings", ->
  #        editorView.trigger keydownEvent('down', ctrlKey: true, altKey: true, metaKey:true, target: editor[0])
  #        editorView.trigger keydownEvent('down', ctrlKey: true, altKey: true, metaKey:true, target: editor[0])
  #        expect(editor.lineForBufferRow(2)).toMatch(/8/)
  #        for i in [0..12] by 1
  #         editorView.trigger keydownEvent('down', ctrlKey: true, altKey: true, metaKey:true, target: editor[0])
  #        expect(editor.lineForBufferRow(2)).toMatch(/\-5/)

  #     describe "decrement by 10", ->
  #       beforeEach ->
  #         editSession.setCursorBufferPosition([3, 12])

  #       it "decrements via commands", ->
  #        editorView.trigger "emmet:decrement-number-by-10"
  #        editorView.trigger "emmet:decrement-number-by-10"
  #        expect(editor.lineForBufferRow(3)).toMatch(/80/)

  #       it "decrements via keybindings", ->
  #        editorView.trigger keydownEvent('down', ctrlKey: true, altKey: true, metaKey: true, shiftKey: true, target: editor[0])
  #        editorView.trigger keydownEvent('down', ctrlKey: true, altKey: true, metaKey: true, shiftKey: true, target: editor[0])
  #        expect(editor.lineForBufferRow(3)).toMatch(/80/)

  # describe "emmet select items", ->
  #   describe "for HTML", ->
  #     beforeEach ->
  #       workspaceView.openSync(Path.join(__dirname, './fixtures/select-item/select-item.html'))
  #       editorView = workspaceView.getActiveView()
  #       editor = editorView.getEditor()
  #       editSession = workspaceView.getActivePaneItem()

  #     describe "selecting next item", ->
  #       beforeEach ->
  #         editSession.setCursorBufferPosition([0, 0])

  #       it "selects next items via commands", ->
  #         editorView.trigger "emmet:select-next-item"
  #         expect(editor.getSelection().getBufferRange()).toEqual [[0, 1], [0, 8]]
  #         editorView.trigger "emmet:select-next-item"
  #         expect(editor.getSelection().getBufferRange()).toEqual [[1, 5], [1, 6]]
  #         editorView.trigger "emmet:select-next-item"
  #         expect(editor.getSelection().getBufferRange()).toEqual [[2, 5], [2, 8]]
  #         editorView.trigger "emmet:select-next-item"
  #         expect(editor.getSelection().getBufferRange()).toEqual [[2, 9], [2, 28]]
  #         editorView.trigger "emmet:select-next-item"
  #         expect(editor.getSelection().getBufferRange()).toEqual [[2, 16], [2, 27]]
  #         editorView.trigger "emmet:select-next-item"
  #         expect(editor.getSelection().getBufferRange()).toEqual [[2, 16], [2, 20]]
  #         editorView.trigger "emmet:select-next-item"
  #         expect(editor.getSelection().getBufferRange()).toEqual [[2, 21], [2, 27]]

  #       it "selects next items via keybindings", ->
  #         editorView.trigger keydownEvent('.', altKey: true, metaKey: true, target: editor[0])
  #         expect(editor.getSelection().getBufferRange()).toEqual [[0, 1], [0, 8]]
  #         editorView.trigger keydownEvent('.', altKey: true, metaKey: true, target: editor[0])
  #         expect(editor.getSelection().getBufferRange()).toEqual [[1, 5], [1, 6]]
  #         editorView.trigger keydownEvent('.', altKey: true, metaKey: true, target: editor[0])
  #         expect(editor.getSelection().getBufferRange()).toEqual [[2, 5], [2, 8]]
  #         editorView.trigger keydownEvent('.', altKey: true, metaKey: true, target: editor[0])
  #         expect(editor.getSelection().getBufferRange()).toEqual [[2, 9], [2, 28]]
  #         editorView.trigger keydownEvent('.', altKey: true, metaKey: true, target: editor[0])
  #         expect(editor.getSelection().getBufferRange()).toEqual [[2, 16], [2, 27]]
  #         editorView.trigger keydownEvent('.', altKey: true, metaKey: true, target: editor[0])
  #         expect(editor.getSelection().getBufferRange()).toEqual [[2, 16], [2, 20]]
  #         editorView.trigger keydownEvent('.', altKey: true, metaKey: true, target: editor[0])
  #         expect(editor.getSelection().getBufferRange()).toEqual [[2, 21], [2, 27]]

  #     describe "selecting previous item", ->
  #       beforeEach ->
  #         editSession.setCursorBufferPosition([2, 21])

  #       it "selects previous items via commands", ->
  #         editorView.trigger "emmet:select-previous-item"
  #         expect(editor.getSelection().getBufferRange()).toEqual [[2, 16], [2, 20]]
  #         editorView.trigger "emmet:select-previous-item"
  #         expect(editor.getSelection().getBufferRange()).toEqual [[2, 16], [2, 27]]
  #         editorView.trigger "emmet:select-previous-item"
  #         expect(editor.getSelection().getBufferRange()).toEqual [[2, 9], [2, 28]]
  #         editorView.trigger "emmet:select-previous-item"
  #         expect(editor.getSelection().getBufferRange()).toEqual [[2, 5], [2, 8]]
  #         editorView.trigger "emmet:select-previous-item"
  #         expect(editor.getSelection().getBufferRange()).toEqual [[1, 5], [1, 6]]
  #         editorView.trigger "emmet:select-previous-item"
  #         expect(editor.getSelection().getBufferRange()).toEqual [[0, 1], [0, 8]]

  #       it "selects previous items via keybindings", ->
  #         editorView.trigger keydownEvent(',', altKey: true, metaKey: true, target: editor[0])
  #         expect(editor.getSelection().getBufferRange()).toEqual [[2, 16], [2, 20]]
  #         editorView.trigger keydownEvent(',', altKey: true, metaKey: true, target: editor[0])
  #         expect(editor.getSelection().getBufferRange()).toEqual [[2, 16], [2, 27]]
  #         editorView.trigger keydownEvent(',', altKey: true, metaKey: true, target: editor[0])
  #         expect(editor.getSelection().getBufferRange()).toEqual [[2, 9], [2, 28]]
  #         editorView.trigger keydownEvent(',', altKey: true, metaKey: true, target: editor[0])
  #         expect(editor.getSelection().getBufferRange()).toEqual [[2, 5], [2, 8]]
  #         editorView.trigger keydownEvent(',', altKey: true, metaKey: true, target: editor[0])
  #         expect(editor.getSelection().getBufferRange()).toEqual [[1, 5], [1, 6]]
  #         editorView.trigger keydownEvent(',', altKey: true, metaKey: true, target: editor[0])
  #         expect(editor.getSelection().getBufferRange()).toEqual [[0, 1], [0, 8]]

  #   describe "for CSS", ->
  #     beforeEach ->
  #       workspaceView.openSync(Path.join(__dirname, './fixtures/select-item/select-item.css'))
  #       editorView = workspaceView.getActiveView()
  #       editor = editorView.getEditor()
  #       editSession = workspaceView.getActivePaneItem()

  #     describe "selecting next item", ->
  #       beforeEach ->
  #         editSession.setCursorBufferPosition([0, 0])

  #       it "selects next items via commands", ->
  #         editorView.trigger "emmet:select-next-item"
  #         expect(editor.getSelection().getBufferRange()).toEqual [[0, 0], [0, 4]]
  #         editorView.trigger "emmet:select-next-item"
  #         expect(editor.getSelection().getBufferRange()).toEqual [[1, 4], [1, 28]]
  #         editorView.trigger "emmet:select-next-item"
  #         expect(editor.getSelection().getBufferRange()).toEqual [[1, 12], [1, 27]]
  #         editorView.trigger "emmet:select-next-item"
  #         expect(editor.getSelection().getBufferRange()).toEqual [[1, 12], [1, 15]]
  #         editorView.trigger "emmet:select-next-item"
  #         expect(editor.getSelection().getBufferRange()).toEqual [[1, 16], [1, 21]]
  #         editorView.trigger "emmet:select-next-item"
  #         expect(editor.getSelection().getBufferRange()).toEqual [[1, 22], [1, 27]]
  #         editorView.trigger "emmet:select-next-item"
  #         expect(editor.getSelection().getBufferRange()).toEqual [[2, 4], [2, 46]]

  #       it "selects next items via keybindings", ->
  #         editorView.trigger keydownEvent('.', altKey: true, metaKey: true, target: editor[0])
  #         expect(editor.getSelection().getBufferRange()).toEqual [[0, 0], [0, 4]]
  #         editorView.trigger keydownEvent('.', altKey: true, metaKey: true, target: editor[0])
  #         expect(editor.getSelection().getBufferRange()).toEqual [[1, 4], [1, 28]]
  #         editorView.trigger keydownEvent('.', altKey: true, metaKey: true, target: editor[0])
  #         expect(editor.getSelection().getBufferRange()).toEqual [[1, 12], [1, 27]]
  #         editorView.trigger keydownEvent('.', altKey: true, metaKey: true, target: editor[0])
  #         expect(editor.getSelection().getBufferRange()).toEqual [[1, 12], [1, 15]]
  #         editorView.trigger keydownEvent('.', altKey: true, metaKey: true, target: editor[0])
  #         expect(editor.getSelection().getBufferRange()).toEqual [[1, 16], [1, 21]]
  #         editorView.trigger keydownEvent('.', altKey: true, metaKey: true, target: editor[0])
  #         expect(editor.getSelection().getBufferRange()).toEqual [[1, 22], [1, 27]]
  #         editorView.trigger keydownEvent('.', altKey: true, metaKey: true, target: editor[0])
  #         expect(editor.getSelection().getBufferRange()).toEqual [[2, 4], [2, 46]]

  #     describe "selecting previous item", ->
  #       beforeEach ->
  #         editSession.setCursorBufferPosition([2, 4])

  #       it "selects previous items via commands", ->
  #         editorView.trigger "emmet:select-previous-item"
  #         expect(editor.getSelection().getBufferRange()).toEqual [[2, 4], [2, 46]]
  #         editorView.trigger "emmet:select-previous-item"
  #         expect(editor.getSelection().getBufferRange()).toEqual [[1, 22], [1, 27]]
  #         editorView.trigger "emmet:select-previous-item"
  #         expect(editor.getSelection().getBufferRange()).toEqual [[1, 16], [1, 21]]
  #         editorView.trigger "emmet:select-previous-item"
  #         expect(editor.getSelection().getBufferRange()).toEqual [[1, 12], [1, 15]]
  #         editorView.trigger "emmet:select-previous-item"
  #         expect(editor.getSelection().getBufferRange()).toEqual [[1, 12], [1, 27]]
  #         editorView.trigger "emmet:select-previous-item"
  #         expect(editor.getSelection().getBufferRange()).toEqual [[1, 4], [1, 28]]

  #       it "selects previous items via keybindings", ->
  #         editorView.trigger keydownEvent(',', altKey: true, metaKey: true, target: editor[0])
  #         expect(editor.getSelection().getBufferRange()).toEqual [[2, 4], [2, 46]]
  #         editorView.trigger keydownEvent(',', altKey: true, metaKey: true, target: editor[0])
  #         expect(editor.getSelection().getBufferRange()).toEqual [[1, 22], [1, 27]]
  #         editorView.trigger keydownEvent(',', altKey: true, metaKey: true, target: editor[0])
  #         expect(editor.getSelection().getBufferRange()).toEqual [[1, 16], [1, 21]]
  #         editorView.trigger keydownEvent(',', altKey: true, metaKey: true, target: editor[0])
  #         expect(editor.getSelection().getBufferRange()).toEqual [[1, 12], [1, 15]]
  #         editorView.trigger keydownEvent(',', altKey: true, metaKey: true, target: editor[0])
  #         expect(editor.getSelection().getBufferRange()).toEqual [[1, 12], [1, 27]]
  #         editorView.trigger keydownEvent(',', altKey: true, metaKey: true, target: editor[0])
  #         expect(editor.getSelection().getBufferRange()).toEqual [[1, 4], [1, 28]]

  # describe "emmet:reflect-css-value", ->
  #   reflection = null

  #   beforeEach ->
  #     workspaceView.openSync(Path.join(__dirname, './fixtures/reflect-css-value/before/reflect-css-value.css'))
  #     editorView = workspaceView.getActiveView()
  #     editor = editorView.getEditor()
  #     editSession = workspaceView.getActivePaneItem()

  #     reflection = Fs.readFileSync(Path.join(__dirname, './fixtures/reflect-css-value/after/reflect-css-value.css'), "utf8")

  #   it "reflects CSS via commands", ->
  #     editor.setCursorBufferPosition([3, 32])
  #     editorView.trigger "emmet:reflect-css-value"
  #     # editor.setCursorBufferPosition([9, 16])
  #     # editorView.trigger "emmet:reflect-css-value"
  #     expect(editor.getText()).toBe reflection

  #   it "reflects CSS via keybindings", ->
  #     editor.setCursorBufferPosition([3, 32])
  #     editorView.trigger keydownEvent('r', shiftKey: true, metaKey: true, target: editor[0])
  #     # editor.setCursorBufferPosition([9, 16])
  #     # editorView.trigger keydownEvent('r', shiftKey: true, metaKey: true, target: editor[0])
  #     expect(editor.getText()).toBe reflection

  # # describe "emmet:encode-decode-data-url", ->
  # #   encoded = null
  # #   beforeEach ->
  # #     workspaceView.openSync(Path.join(__dirname, './fixtures/encode-decode-data-url/before/encode-decode-data-url.css'))
  # #     editorView = workspaceView.getActiveView()
  # #     editor = editorView.getEditor()
  # #     editSession = workspaceView.getActivePaneItem()
  # #
  # #     editSession.setCursorBufferPosition([1, 22])
  # #
  # #     encoded = Fs.readFileSync(Path.join(__dirname, './fixtures/encode-decode-data-url/after/encode-decode-data-url.css'), "utf8")
  # #
  # #   it "encodes and decodes URL via commands", ->
  # #     editorView.trigger "emmet:encode-decode-data-url"
  # #     expect(editor.getText()).toBe encoded
  # #
  # #   it "encodes and decodes CSS via keybindings", ->
  # #     editorView.trigger keydownEvent('d', shiftKey: true, ctrlKey: true, target: editor[0])
  # #     expect(editor.getText()).toBe encoded

  # # describe "emmet:update-image-size", ->
  # #   updated = null
  # #
  # #   describe "for HTML", ->
  # #     beforeEach ->
  # #       workspaceView.openSync(Path.join(__dirname, './fixtures/update-image-size/before/update-image-size.html'))
  # #       editorView = workspaceView.getActiveView()
  # #       editor = editorView.getEditor()
  # #       editSession = workspaceView.getActivePaneItem()
  # #       editSession.setCursorBufferPosition([0, 15])
  # #
  # #       updated = Fs.readFileSync(Path.join(__dirname, './fixtures/update-image-size/after/update-image-size.html'), "utf8")
  # #
  # #     it "updates the image via commands", ->
  # #       editorView.trigger "emmet:update-image-size"
  # #       expect(editor.getText()).toBe updated
  # #
  # #     it "updates the image via keybindings", ->
  # #       editorView.trigger keydownEvent('i', shiftKey: true, ctrlKey: true, target: editor[0])
  # #       expect(editor.getText()).toBe updated
  # #
  # #   describe "for CSS", ->
  # #     beforeEach ->
  # #       workspaceView.openSync(Path.join(__dirname, './fixtures/update-image-size/before/update-image-size.css'))
  # #       editorView = workspaceView.getActiveView()
  # #       editor = editorView.getEditor()
  # #       editSession = workspaceView.getActivePaneItem()
  # #       editSession.setCursorBufferPosition([0, 15])
  # #
  # #       updated = Fs.readFileSync(Path.join(__dirname, './fixtures/update-image-size/after/update-image-size.css'), "utf8")
  # #
  # #     it "updates the image via commands", ->
  # #       editorView.trigger "emmet:update-image-size"
  # #       expect(editor.getText()).toBe updated
  # #
  # #     it "updates the image via keybindings", ->
  # #       editorView.trigger keydownEvent('i', shiftKey: true, ctrlKey: true, target: editor[0])
  # #       expect(editor.getText()).toBe updated

  # describe "emmet:update-tag", ->
  #   updated = null
  #   prompt = null

  #   describe "for HTML", ->
  #     beforeEach ->
  #       workspaceView.openSync(Path.join(__dirname, './fixtures/update-tag/before/update-tag.html'))
  #       editorView = workspaceView.getActiveView()
  #       editor = editorView.getEditor()
  #       editSession = workspaceView.getActivePaneItem()
  #       editSession.setCursorBufferPosition([0, 11])

  #       updated = Fs.readFileSync(Path.join(__dirname, './fixtures/update-tag/after/update-tag.html'), "utf8")

  #     it "updates the tag via commands", ->
  #       editorView.trigger "emmet:update-tag"
  #       prompt = atom.workspaceView.find(".emmet-prompt").view()

  #       prompt.panelInput.insertText(".+c2[title=Hello]")
  #       prompt.trigger 'core:confirm'

  #       expect(editor.getText()).toBe updated

  #     it "updates the tag via keybindings", ->
  #       editorView.trigger keydownEvent('u', shiftKey: true, ctrlKey: true, target: editor[0])

  #       prompt.panelInput.insertText(".+c2[title=Hello]")
  #       prompt.trigger 'core:confirm'

  #       expect(editor.getText()).toBe updated

  # describe "emmet:wrap-with-abbreviation", ->
  #   updated = null
  #   prompt = null

  #   describe "for HTML", ->
  #     beforeEach ->
  #       workspaceView.openSync(Path.join(__dirname, './fixtures/wrap-with-abbreviation/before/wrap-with-abbreviation.html'))
  #       editorView = workspaceView.getActiveView()
  #       editor = editorView.getEditor()
  #       editSession = workspaceView.getActivePaneItem()
  #       editSession.setCursorBufferPosition([1, 4])

  #       updated = Fs.readFileSync(Path.join(__dirname, './fixtures/wrap-with-abbreviation/after/wrap-with-abbreviation.html'), "utf8")

  #     it "wraps an abbreviation via commands", ->
  #       editorView.trigger "emmet:wrap-with-abbreviation"
  #       prompt = atom.workspaceView.find(".emmet-prompt").view()

  #       prompt.panelInput.setText(".wrapper>h1{Title}+.content")
  #       prompt.trigger 'core:confirm'

  #       expect(editor.getText()).toBe updated

  #     it "wraps an abbreviation via keybindings", ->
  #       editorView.trigger keydownEvent('a', shiftKey: true, metaKey: true, target: editor[0])
  #       prompt = atom.workspaceView.find(".emmet-prompt").view()

  #       prompt.panelInput.setText(".wrapper>h1{Title}+.content")
  #       prompt.trigger 'core:confirm'

  #       expect(editor.getText()).toBe updated

  # describe "emmet:merge-lines", ->
  #   updated = null

  #   describe "for HTML", ->
  #     beforeEach ->
  #       workspaceView.openSync(Path.join(__dirname, './fixtures/merge-lines/before/merge-lines.html'))
  #       editorView = workspaceView.getActiveView()
  #       editor = editorView.getEditor()
  #       editSession = workspaceView.getActivePaneItem()
  #       editSession.setCursorBufferPosition([3, 5])

  #       updated = Fs.readFileSync(Path.join(__dirname, './fixtures/merge-lines/after/merge-lines.html'), "utf8")

  #     it "performs merge lines via commands", ->
  #       editorView.trigger "emmet:merge-lines"
  #       expect(editor.getText()).toBe updated

  #     it "performs merge lines via keybindings", ->
  #       editorView.trigger keydownEvent('M', shiftKey: true, metaKey: true, target: editor[0])
  #       expect(editor.getText()).toBe updated
