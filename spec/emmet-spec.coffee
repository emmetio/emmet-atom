{WorkspaceView} = require 'atom'
Path = require 'path'
Fs = require 'fs'

describe "Emmet", ->
  [buffer, editor, editSession, workspaceView] = []

  beforeEach ->
    atom.workspaceView = new WorkspaceView
    workspaceView = atom.workspaceView

    atom.packages.activatePackage("emmet")
    atom.packages.activatePackage("snippets") # intentionally disrupt tab expansion
    atom.packages.activatePackage('language-css', sync: true)
    atom.packages.activatePackage('language-html', sync: true)

    workspaceView.simulateDomAttachment()
    workspaceView.enableKeymap()

  afterEach ->
    editSession.destroy()

  fdescribe "emmet:expand-abbreviation", ->
    expansion = null

    describe "for normal HTML", ->
      beforeEach ->
        workspaceView.openSync(Path.join(__dirname, './fixtures/abbreviation/before/html-abbrv.html'))
        editor = workspaceView.getActiveView()
        editSession = workspaceView.getActivePaneItem()
        editSession.moveCursorToEndOfLine()

        expansion = Fs.readFileSync(Path.join(__dirname, './fixtures/abbreviation/after/html-abbrv.html'), "utf8")

      it "expands HTML abbreviations via commands", ->
        editor.trigger "emmet:expand-abbreviation"
        expect(editor.getText()).toBe expansion

      it "expands HTML abbreviations via keybindings", ->
        editor.trigger keydownEvent('e', shiftKey: true, metaKey: true, target: editor[0])
        expect(editor.getText()).toBe expansion

      it "expands HTML abbreviations via Tab", ->
        editor.trigger keydownEvent('tab', target: editor[0])
        expect(editor.getText()).toBe expansion

    # headers seem to be a special case: http://git.io/7XeBKQ
    fdescribe "for headers in HTML", ->
      beforeEach ->
        workspaceView.openSync(Path.join(__dirname, './fixtures/abbreviation/before/header-expand.html'))
        editor = workspaceView.getActiveView()
        editSession = workspaceView.getActivePaneItem()
        editSession.moveCursorToEndOfLine()

        expansion = Fs.readFileSync(Path.join(__dirname, './fixtures/abbreviation/after/header-expand.html'), "utf8")

      it "expands HTML abbreviations via commands", ->
        editor.trigger "emmet:expand-abbreviation"
        expect(editor.getText()).toBe expansion

      it "expands HTML abbreviations via keybindings", ->
        editor.trigger keydownEvent('e', shiftKey: true, metaKey: true, target: editor[0])
        expect(editor.getText()).toBe expansion

      it "expands HTML abbreviations via Tab", ->
        editor.trigger keydownEvent('tab', target: editor[0])
        expect(editor.getText()).toBe expansion

    describe "for CSS", ->
      beforeEach ->
        workspaceView.openSync(Path.join(__dirname, './fixtures/abbreviation/before/css-abbrv.css'))
        editor = workspaceView.getActiveView()
        editSession = workspaceView.getActivePaneItem()
        editSession.moveCursorToEndOfLine()

        expansion = Fs.readFileSync(Path.join(__dirname, './fixtures/abbreviation/after/css-abbrv.css'), "utf8")

      it "expands CSS abbreviations via commands", ->
        editor.trigger "emmet:expand-abbreviation"
        expect(editor.getText()).toBe expansion

      it "expands CSS abbreviations via keybindings", ->
        editor.trigger keydownEvent('e', shiftKey: true, metaKey: true, target: editor[0])
        expect(editor.getText()).toBe expansion

      it "expands CSS abbreviations via tab", ->
        editor.trigger keydownEvent('tab', target: editor[0])
        expect(editor.getText()).toBe expansion

  describe "emmet:match-pair", ->
    beforeEach ->
      workspaceView.openSync(Path.join(__dirname, './fixtures/match-pair/sample.html'))
      editor = workspaceView.getActiveView()
      editSession = workspaceView.getActivePaneItem()

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
        editSession.setCursorBufferPosition([1, 4])

      it "matches pairs inwards via commands", ->
        editor.trigger "emmet:match-pair-inward"
        expect(editor.getSelection().getBufferRange()).toEqual [[0, 15], [5, 0]]
        editor.trigger "emmet:match-pair-inward"
        expect(editor.getSelection().getBufferRange()).toEqual [[1, 4], [4, 14]]
        editor.trigger "emmet:match-pair-inward"
        expect(editor.getSelection().getBufferRange()).toEqual [[1, 29], [4, 4]]
        editor.trigger "emmet:match-pair-inward"
        expect(editor.getSelection().getBufferRange()).toEqual [[2, 8], [2, 33]]

      it "matches pairs inwards via keybindings", ->
        editor.trigger keydownEvent('d', altKey: true, target: editor[0])
        expect(editor.getSelection().getBufferRange()).toEqual [[0, 15], [5, 0]]
        editor.trigger keydownEvent('d', altKey: true, target: editor[0])
        expect(editor.getSelection().getBufferRange()).toEqual [[1, 4], [4, 14]]
        editor.trigger keydownEvent('d', altKey: true, target: editor[0])
        expect(editor.getSelection().getBufferRange()).toEqual [[1, 29], [4, 4]]
        editor.trigger keydownEvent('d', altKey: true, target: editor[0])
        expect(editor.getSelection().getBufferRange()).toEqual [[2, 8], [2, 33]]

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
      workspaceView.openSync(Path.join(__dirname, './fixtures/edit-points/edit-points.html'))
      editor = workspaceView.getActiveView()
      editSession = workspaceView.getActivePaneItem()

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
        editor.trigger keydownEvent('.', ctrlKey: true, altKey:true, target: editor[0])
        expect(editor.getCursor().getBufferPosition()).toEqual [1, 8]
        editor.trigger keydownEvent('.', ctrlKey: true, altKey:true, target: editor[0])
        expect(editor.getCursor().getBufferPosition()).toEqual [1, 17]
        editor.trigger keydownEvent('.', ctrlKey: true, altKey:true, target: editor[0])
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
        editor.trigger keydownEvent(',', ctrlKey: true, altKey:true, target: editor[0])
        expect(editor.getCursor().getBufferPosition()).toEqual [2, 23]
        editor.trigger keydownEvent(',', ctrlKey: true, altKey:true, target: editor[0])
        expect(editor.getCursor().getBufferPosition()).toEqual [2, 19]
        editor.trigger keydownEvent(',', ctrlKey: true, altKey:true, target: editor[0])
        expect(editor.getCursor().getBufferPosition()).toEqual [2, 17]

  describe "emmet:split-join-tag", ->
    beforeEach ->
      workspaceView.openSync(Path.join(__dirname, './fixtures/split-join-tag/split-join-tag.html'))
      editor = workspaceView.getActiveView()
      editSession = workspaceView.getActivePaneItem()

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

  describe "emmet:remove-tag", ->
    onceRemoved = twiceRemoved = null

    beforeEach ->
      workspaceView.openSync(Path.join(__dirname, './fixtures/remove-tag/before/remove-tag.html'))
      editor = workspaceView.getActiveView()
      editSession = workspaceView.getActivePaneItem()

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

  describe "emmet:evaluate-math-expression", ->
    beforeEach ->
      workspaceView.openSync(Path.join(__dirname, './fixtures/evaluate-math-expression/evaluate-math-expression.html'))
      editor = workspaceView.getActiveView()
      editSession = workspaceView.getActivePaneItem()

    describe "for evaluate-math-expression", ->
      it "calls evaluate-math-expression via commands", ->
        editSession.setCursorBufferPosition([0, 3])
        editor.trigger "emmet:evaluate-math-expression"
        editSession.setCursorBufferPosition([0, 7])
        editor.trigger "emmet:evaluate-math-expression"
        editSession.setCursorBufferPosition([0, 12])
        editor.trigger "emmet:evaluate-math-expression"
        expect(editor.getText()).toBe "12 3 90\n"

      it "calls evaluate-math-expression via keybindings", ->
       editSession.setCursorBufferPosition([0, 3])
       editor.trigger keydownEvent('y', shiftKey: true, metaKey: true, target: editor[0])
       editSession.setCursorBufferPosition([0, 7])
       editor.trigger keydownEvent('y', shiftKey: true, metaKey: true, target: editor[0])
       editSession.setCursorBufferPosition([0, 12])
       editor.trigger keydownEvent('y', shiftKey: true, metaKey: true, target: editor[0])
       expect(editor.getText()).toBe "12 3 90\n"

  describe "emmet increment/decrement numbers", ->
     beforeEach ->
       workspaceView.openSync(Path.join(__dirname, './fixtures/increment-decrement-numbers/increment-decrement-numbers.css'))
       editor = workspaceView.getActiveView()
       editSession = workspaceView.getActivePaneItem()

     describe "for incrementing", ->
       describe "increment by 01", ->
         beforeEach ->
          editSession.setCursorBufferPosition([1, 18])

         it "increments via commands", ->
          editor.trigger "emmet:increment-number-by-01"
          editor.trigger "emmet:increment-number-by-01"
          expect(editor.lineForBufferRow(1)).toMatch(/1\.9/)
          editor.trigger "emmet:increment-number-by-01"
          editor.trigger "emmet:increment-number-by-01"
          expect(editor.lineForBufferRow(1)).toMatch(/2\.1/)

         it "increments via keybindings", ->
          editor.trigger "emmet:increment-number-by-01"
          editor.trigger "emmet:increment-number-by-01"
          editor.trigger keydownEvent('up', shiftKey: true, altKey: true, target: editor[0])
          editor.trigger "emmet:increment-number-by-01"
          editor.trigger "emmet:increment-number-by-01"
          editor.trigger keydownEvent('up', shiftKey: true, altKey: true, target: editor[0])

      describe "increment by 1", ->
        beforeEach ->
          editSession.setCursorBufferPosition([2, 13])

        it "increments via commands", ->
         editor.trigger "emmet:increment-number-by-1"
         editor.trigger "emmet:increment-number-by-1"
         expect(editor.lineForBufferRow(2)).toMatch(/12/)
         for i in [0..12] by 1
           editor.trigger "emmet:increment-number-by-1"
         expect(editor.lineForBufferRow(2)).toMatch(/25/)

        it "increments via keybindings", ->
         editor.trigger keydownEvent('up', shiftKey: true, ctrlKey: true, target: editor[0])
         editor.trigger keydownEvent('up', shiftKey: true, ctrlKey: true, target: editor[0])
         expect(editor.lineForBufferRow(2)).toMatch(/12/)
         for i in [0..12] by 1
           editor.trigger keydownEvent('up', shiftKey: true, ctrlKey: true, target: editor[0])
         expect(editor.lineForBufferRow(2)).toMatch(/25/)

      describe "increment by 10", ->
        beforeEach ->
          editSession.setCursorBufferPosition([3, 12])

        it "increments via commands", ->
         editor.trigger "emmet:increment-number-by-10"
         editor.trigger "emmet:increment-number-by-10"
         expect(editor.lineForBufferRow(3)).toMatch(/120/)

        it "increments via keybindings", ->
         editor.trigger keydownEvent('up', altKey: true, ctrlKey: true, target: editor[0])
         editor.trigger keydownEvent('up', altKey: true, ctrlKey: true, target: editor[0])
         expect(editor.lineForBufferRow(3)).toMatch(/120/)

     describe "for decrementing", ->
       describe "decrement by 01", ->
         beforeEach ->
          editSession.setCursorBufferPosition([1, 18])

         it "decrements via commands", ->
          editor.trigger "emmet:decrement-number-by-01"
          editor.trigger "emmet:decrement-number-by-01"
          expect(editor.lineForBufferRow(1)).toMatch(/1\.5/)
          for i in [0..20] by 1
            editor.trigger "emmet:decrement-number-by-01"
          expect(editor.lineForBufferRow(1)).toMatch(/\-0\.6/)

         it "decrements via keybindings", ->
          editor.trigger keydownEvent('down', shiftKey: true, altKey: true, target: editor[0])
          editor.trigger keydownEvent('down', shiftKey: true, altKey: true, target: editor[0])
          expect(editor.lineForBufferRow(1)).toMatch(/1\.5/)
          for i in [0..20] by 1
            editor.trigger keydownEvent('down', shiftKey: true, altKey: true, target: editor[0])
          expect(editor.lineForBufferRow(1)).toMatch(/\-0\.6/)

      describe "decrement by 1", ->
        beforeEach ->
          editSession.setCursorBufferPosition([2, 13])

        it "decrements via commands", ->
         editor.trigger "emmet:decrement-number-by-1"
         editor.trigger "emmet:decrement-number-by-1"
         expect(editor.lineForBufferRow(2)).toMatch(/8/)
         for i in [0..12] by 1
           editor.trigger "emmet:decrement-number-by-1"
         expect(editor.lineForBufferRow(2)).toMatch(/\-5/)

        it "decrements via keybindings", ->
         editor.trigger keydownEvent('down', shiftKey: true, ctrlKey: true, target: editor[0])
         editor.trigger keydownEvent('down', shiftKey: true, ctrlKey: true, target: editor[0])
         expect(editor.lineForBufferRow(2)).toMatch(/8/)
         for i in [0..12] by 1
          editor.trigger keydownEvent('down', shiftKey: true, ctrlKey: true, target: editor[0])
         expect(editor.lineForBufferRow(2)).toMatch(/\-5/)

      describe "decrement by 10", ->
        beforeEach ->
          editSession.setCursorBufferPosition([3, 12])

        it "decrements via commands", ->
         editor.trigger "emmet:decrement-number-by-10"
         editor.trigger "emmet:decrement-number-by-10"
         expect(editor.lineForBufferRow(3)).toMatch(/80/)

        it "decrements via keybindings", ->
         editor.trigger keydownEvent('down', altKey: true, ctrlKey: true, target: editor[0])
         editor.trigger keydownEvent('down', altKey: true, ctrlKey: true, target: editor[0])
         expect(editor.lineForBufferRow(3)).toMatch(/80/)

  describe "emmet select items", ->
    describe "for HTML", ->
      beforeEach ->
        workspaceView.openSync(Path.join(__dirname, './fixtures/select-item/select-item.html'))
        editor = workspaceView.getActiveView()
        editSession = workspaceView.getActivePaneItem()

      describe "selecting next item", ->
        beforeEach ->
          editSession.setCursorBufferPosition([0, 0])

        it "selects next items via commands", ->
          editor.trigger "emmet:select-next-item"
          expect(editor.getSelection().getBufferRange()).toEqual [[0, 1], [0, 8]]
          editor.trigger "emmet:select-next-item"
          expect(editor.getSelection().getBufferRange()).toEqual [[1, 5], [1, 6]]
          editor.trigger "emmet:select-next-item"
          expect(editor.getSelection().getBufferRange()).toEqual [[2, 5], [2, 8]]
          editor.trigger "emmet:select-next-item"
          expect(editor.getSelection().getBufferRange()).toEqual [[2, 9], [2, 28]]
          editor.trigger "emmet:select-next-item"
          expect(editor.getSelection().getBufferRange()).toEqual [[2, 16], [2, 27]]
          editor.trigger "emmet:select-next-item"
          expect(editor.getSelection().getBufferRange()).toEqual [[2, 16], [2, 20]]
          editor.trigger "emmet:select-next-item"
          expect(editor.getSelection().getBufferRange()).toEqual [[2, 21], [2, 27]]

        it "selects next items via keybindings", ->
          editor.trigger keydownEvent('.', altKey: true, metaKey: true, target: editor[0])
          expect(editor.getSelection().getBufferRange()).toEqual [[0, 1], [0, 8]]
          editor.trigger keydownEvent('.', altKey: true, metaKey: true, target: editor[0])
          expect(editor.getSelection().getBufferRange()).toEqual [[1, 5], [1, 6]]
          editor.trigger keydownEvent('.', altKey: true, metaKey: true, target: editor[0])
          expect(editor.getSelection().getBufferRange()).toEqual [[2, 5], [2, 8]]
          editor.trigger keydownEvent('.', altKey: true, metaKey: true, target: editor[0])
          expect(editor.getSelection().getBufferRange()).toEqual [[2, 9], [2, 28]]
          editor.trigger keydownEvent('.', altKey: true, metaKey: true, target: editor[0])
          expect(editor.getSelection().getBufferRange()).toEqual [[2, 16], [2, 27]]
          editor.trigger keydownEvent('.', altKey: true, metaKey: true, target: editor[0])
          expect(editor.getSelection().getBufferRange()).toEqual [[2, 16], [2, 20]]
          editor.trigger keydownEvent('.', altKey: true, metaKey: true, target: editor[0])
          expect(editor.getSelection().getBufferRange()).toEqual [[2, 21], [2, 27]]

      describe "selecting previous item", ->
        beforeEach ->
          editSession.setCursorBufferPosition([2, 21])

        it "selects previous items via commands", ->
          editor.trigger "emmet:select-previous-item"
          expect(editor.getSelection().getBufferRange()).toEqual [[2, 16], [2, 20]]
          editor.trigger "emmet:select-previous-item"
          expect(editor.getSelection().getBufferRange()).toEqual [[2, 16], [2, 27]]
          editor.trigger "emmet:select-previous-item"
          expect(editor.getSelection().getBufferRange()).toEqual [[2, 9], [2, 28]]
          editor.trigger "emmet:select-previous-item"
          expect(editor.getSelection().getBufferRange()).toEqual [[2, 5], [2, 8]]
          editor.trigger "emmet:select-previous-item"
          expect(editor.getSelection().getBufferRange()).toEqual [[1, 5], [1, 6]]
          editor.trigger "emmet:select-previous-item"
          expect(editor.getSelection().getBufferRange()).toEqual [[0, 1], [0, 8]]

        it "selects previous items via keybindings", ->
          editor.trigger keydownEvent(',', altKey: true, metaKey: true, target: editor[0])
          expect(editor.getSelection().getBufferRange()).toEqual [[2, 16], [2, 20]]
          editor.trigger keydownEvent(',', altKey: true, metaKey: true, target: editor[0])
          expect(editor.getSelection().getBufferRange()).toEqual [[2, 16], [2, 27]]
          editor.trigger keydownEvent(',', altKey: true, metaKey: true, target: editor[0])
          expect(editor.getSelection().getBufferRange()).toEqual [[2, 9], [2, 28]]
          editor.trigger keydownEvent(',', altKey: true, metaKey: true, target: editor[0])
          expect(editor.getSelection().getBufferRange()).toEqual [[2, 5], [2, 8]]
          editor.trigger keydownEvent(',', altKey: true, metaKey: true, target: editor[0])
          expect(editor.getSelection().getBufferRange()).toEqual [[1, 5], [1, 6]]
          editor.trigger keydownEvent(',', altKey: true, metaKey: true, target: editor[0])
          expect(editor.getSelection().getBufferRange()).toEqual [[0, 1], [0, 8]]

    describe "for CSS", ->
      beforeEach ->
        workspaceView.openSync(Path.join(__dirname, './fixtures/select-item/select-item.css'))
        editor = workspaceView.getActiveView()
        editSession = workspaceView.getActivePaneItem()

      describe "selecting next item", ->
        beforeEach ->
          editSession.setCursorBufferPosition([0, 0])

        it "selects next items via commands", ->
          editor.trigger "emmet:select-next-item"
          expect(editor.getSelection().getBufferRange()).toEqual [[0, 0], [0, 4]]
          editor.trigger "emmet:select-next-item"
          expect(editor.getSelection().getBufferRange()).toEqual [[1, 4], [1, 28]]
          editor.trigger "emmet:select-next-item"
          expect(editor.getSelection().getBufferRange()).toEqual [[1, 12], [1, 27]]
          editor.trigger "emmet:select-next-item"
          expect(editor.getSelection().getBufferRange()).toEqual [[1, 12], [1, 15]]
          editor.trigger "emmet:select-next-item"
          expect(editor.getSelection().getBufferRange()).toEqual [[1, 16], [1, 21]]
          editor.trigger "emmet:select-next-item"
          expect(editor.getSelection().getBufferRange()).toEqual [[1, 22], [1, 27]]
          editor.trigger "emmet:select-next-item"
          expect(editor.getSelection().getBufferRange()).toEqual [[2, 4], [2, 46]]

        it "selects next items via keybindings", ->
          editor.trigger keydownEvent('.', altKey: true, metaKey: true, target: editor[0])
          expect(editor.getSelection().getBufferRange()).toEqual [[0, 0], [0, 4]]
          editor.trigger keydownEvent('.', altKey: true, metaKey: true, target: editor[0])
          expect(editor.getSelection().getBufferRange()).toEqual [[1, 4], [1, 28]]
          editor.trigger keydownEvent('.', altKey: true, metaKey: true, target: editor[0])
          expect(editor.getSelection().getBufferRange()).toEqual [[1, 12], [1, 27]]
          editor.trigger keydownEvent('.', altKey: true, metaKey: true, target: editor[0])
          expect(editor.getSelection().getBufferRange()).toEqual [[1, 12], [1, 15]]
          editor.trigger keydownEvent('.', altKey: true, metaKey: true, target: editor[0])
          expect(editor.getSelection().getBufferRange()).toEqual [[1, 16], [1, 21]]
          editor.trigger keydownEvent('.', altKey: true, metaKey: true, target: editor[0])
          expect(editor.getSelection().getBufferRange()).toEqual [[1, 22], [1, 27]]
          editor.trigger keydownEvent('.', altKey: true, metaKey: true, target: editor[0])
          expect(editor.getSelection().getBufferRange()).toEqual [[2, 4], [2, 46]]

      describe "selecting previous item", ->
        beforeEach ->
          editSession.setCursorBufferPosition([2, 4])

        it "selects previous items via commands", ->
          editor.trigger "emmet:select-previous-item"
          expect(editor.getSelection().getBufferRange()).toEqual [[1, 22], [1, 27]]
          editor.trigger "emmet:select-previous-item"
          expect(editor.getSelection().getBufferRange()).toEqual [[1, 16], [1, 21]]
          editor.trigger "emmet:select-previous-item"
          expect(editor.getSelection().getBufferRange()).toEqual [[1, 12], [1, 15]]
          editor.trigger "emmet:select-previous-item"
          expect(editor.getSelection().getBufferRange()).toEqual [[1, 12], [1, 27]]
          editor.trigger "emmet:select-previous-item"
          expect(editor.getSelection().getBufferRange()).toEqual [[1, 4], [1, 28]]
          editor.trigger "emmet:select-previous-item"
          expect(editor.getSelection().getBufferRange()).toEqual [[0, 0], [0, 4]]

        it "selects previous items via keybindings", ->
          editor.trigger keydownEvent(',', altKey: true, metaKey: true, target: editor[0])
          expect(editor.getSelection().getBufferRange()).toEqual [[1, 22], [1, 27]]
          editor.trigger keydownEvent(',', altKey: true, metaKey: true, target: editor[0])
          expect(editor.getSelection().getBufferRange()).toEqual [[1, 16], [1, 21]]
          editor.trigger keydownEvent(',', altKey: true, metaKey: true, target: editor[0])
          expect(editor.getSelection().getBufferRange()).toEqual [[1, 12], [1, 15]]
          editor.trigger keydownEvent(',', altKey: true, metaKey: true, target: editor[0])
          expect(editor.getSelection().getBufferRange()).toEqual [[1, 12], [1, 27]]
          editor.trigger keydownEvent(',', altKey: true, metaKey: true, target: editor[0])
          expect(editor.getSelection().getBufferRange()).toEqual [[1, 4], [1, 28]]
          editor.trigger keydownEvent(',', altKey: true, metaKey: true, target: editor[0])
          expect(editor.getSelection().getBufferRange()).toEqual [[0, 0], [0, 4]]

  describe "emmet:reflect-css-value", ->
    reflection = null

    describe "for HTML", ->
      beforeEach ->
        workspaceView.openSync(Path.join(__dirname, './fixtures/reflect-css-value/before/reflect-css-value.css'))
        editor = workspaceView.getActiveView()
        editSession = workspaceView.getActivePaneItem()

        reflection = Fs.readFileSync(Path.join(__dirname, './fixtures/reflect-css-value/after/reflect-css-value.css'), "utf8")

      it "reflects CSS via commands", ->
        editor.setCursorBufferPosition([3, 32])
        editor.trigger "emmet:reflect-css-value"
        editor.setCursorBufferPosition([9, 16])
        editor.trigger "emmet:reflect-css-value"
        expect(editor.getText()).toBe reflection

      it "reflects CSS via keybindings", ->
        editor.setCursorBufferPosition([3, 32])
        editor.trigger keydownEvent('r', shiftKey: true, metaKey: true, target: editor[0])
        editor.setCursorBufferPosition([9, 16])
        editor.trigger keydownEvent('r', shiftKey: true, metaKey: true, target: editor[0])
        expect(editor.getText()).toBe reflection

  describe "emmet:encode-decode-data-url", ->
    encoded = null
    beforeEach ->
      workspaceView.open(Path.join(__dirname, './fixtures/encode-decode-data-url/before/encode-decode-data-url.css'))
      editor = workspaceView.getActiveView()
      editSession = workspaceView.getActivePaneItem()

      editSession.setCursorBufferPosition([1, 22])

      encoded = Fs.readFileSync(Path.join(__dirname, './fixtures/encode-decode-data-url/after/encode-decode-data-url.css'), "utf8")

    it "encodes and decodes URL via commands", ->
      editor.trigger "emmet:encode-decode-data-url"
      expect(editor.getText()).toBe encoded

    it "encodes and decodes CSS via keybindings", ->
      editor.trigger keydownEvent('d', shiftKey: true, ctrlKey: true, target: editor[0])
      expect(editor.getText()).toBe encoded

  describe "emmet:update-image-size", ->
    updated = null

    describe "for HTML", ->
      beforeEach ->
        workspaceView.open(Path.join(__dirname, './fixtures/update-image-size/before/update-image-size.html'))
        editor = workspaceView.getActiveView()
        editSession = workspaceView.getActivePaneItem()
        editSession.setCursorBufferPosition([0, 15])

        updated = Fs.readFileSync(Path.join(__dirname, './fixtures/update-image-size/after/update-image-size.html'), "utf8")

      it "updates the image via commands", ->
        editor.trigger "emmet:update-image-size"
        expect(editor.getText()).toBe updated

      it "updates the image via keybindings", ->
        editor.trigger keydownEvent('i', shiftKey: true, ctrlKey: true, target: editor[0])
        expect(editor.getText()).toBe updated

    describe "for CSS", ->
      beforeEach ->
        workspaceView.open(Path.join(__dirname, './fixtures/update-image-size/before/update-image-size.css'))
        editor = workspaceView.getActiveView()
        editSession = workspaceView.getActivePaneItem()
        editSession.setCursorBufferPosition([0, 15])

        updated = Fs.readFileSync(Path.join(__dirname, './fixtures/update-image-size/after/update-image-size.css'), "utf8")

      it "updates the image via commands", ->
        editor.trigger "emmet:update-image-size"
        expect(editor.getText()).toBe updated

      it "updates the image via keybindings", ->
        editor.trigger keydownEvent('i', shiftKey: true, ctrlKey: true, target: editor[0])
        expect(editor.getText()).toBe updated
