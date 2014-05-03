path = require 'path'

emmet        = require 'emmet'
emmetActions = require 'emmet/lib/action/main'
resources    = require 'emmet/lib/assets/resources'

editorProxy  = require './editor-proxy'
interactive  = require './interactive'

singleSelectionActions = [
  'prev_edit_point', 'next_edit_point', 'merge_lines',
  'reflect_css_value', 'select_next_item', 'select_previous_item',
  'wrap_with_abbreviation', 'update_tag', 'insert_formatted_line_break_only'
]

# Emmet action decorator: creates a command function
# for Atom and executes Emmet action as single
# undo command
# @param  {Object} action Action to perform
# @return {Function}
actionDecorator = (action) ->
  (editorView, evt) ->
    editorProxy.setup(editorView)
    editorProxy.editor.transact =>
      runAction action, evt

# Same as `actionDecorator()` but executes action
# with multiple selections
# @param  {Object} action Action to perform
# @return {Function}
multiSelectionActionDecorator = (action) ->
  (editorView, evt) ->
    editorProxy.setup(editorView)
    editorProxy.editor.transact =>
      editorProxy.exec (i) ->
        runAction action, evt
        return false if evt.keyBindingAborted

runAction = (action, evt) ->
  if action is 'expand_abbreviation_with_tab'
    # do not handle Tab key for unknown syntaxes
    activeEditor = editorProxy.editor;
    syntax = editorProxy.getSyntax()
    if not resources.hasSyntax(syntax) or not activeEditor.getSelection().isEmpty()
      return evt.abortKeyBinding()

  emmet.run action, editorProxy

atomActionName = (name) ->
  'emmet:' + name.replace(/_/g, '-')

registerInteractiveActions = (actions) ->
  for name in ['wrap_with_abbreviation', 'update_tag', 'interactive_expand_abbreviation']
    do (name) ->
      atomAction = atomActionName name
      actions[atomAction] = (editorView, evt) ->
        console.log 'run interactive'
        editorProxy.setup(editorView)
        interactive.run(name, editorProxy)

module.exports =
  editorSubscription: null

  activate: (@state) ->
    unless @actions
      @actions = {}
      registerInteractiveActions @actions
      for action in emmetActions.getList()
        atomAction = atomActionName action.name
        if @actions[atomAction]?
          continue
        cmd = if singleSelectionActions.indexOf(action.name) isnt -1 then actionDecorator(action.name) else multiSelectionActionDecorator(action.name)
        @actions[atomAction] = cmd

    @editorViewSubscription = atom.workspaceView.eachEditorView (editorView) =>
      if editorView.attached and not editorView.mini
        for name, action of @actions
          do (name, action) =>
            editorView.command name, (e) =>
              console.log 'run', name
              action(editorView, e)

  deactivate: ->
    @editorViewSubscription?.off()
    @editorViewSubscription = null