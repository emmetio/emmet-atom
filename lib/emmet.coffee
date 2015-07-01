path = require 'path'
fs = require 'fs'
{CompositeDisposable} = require 'atom'

emmet = require 'emmet'
emmetActions = require 'emmet/lib/action/main'
resources = require 'emmet/lib/assets/resources'

editorProxy  = require './editor-proxy'
# interactive  = require './interactive'

singleSelectionActions = [
  'prev_edit_point', 'next_edit_point', 'merge_lines',
  'reflect_css_value', 'select_next_item', 'select_previous_item',
  'wrap_with_abbreviation', 'update_tag'
]

toggleCommentSyntaxes = ['html', 'css', 'less', 'scss']

getUserHome = () ->
  if process.platform is 'win32'
    return process.env.USERPROFILE

  process.env.HOME

isValidTabContext = () ->
  if editorProxy.getGrammar() is 'html'
    # HTML may contain embedded grammars
    scopes = editorProxy.getCurrentScope()
    contains = (regexp) -> scopes.filter((s) -> regexp.test s).length

    if contains /\.js\.embedded\./
      # in JS, allow Tab expander only inside string
      return contains /^string\./

  return true


# Emmet action decorator: creates a command function
# for Atom and executes Emmet action as single
# undo command
# @param  {Object} action Action to perform
# @return {Function}
actionDecorator = (action) ->
  (evt) ->
    editorProxy.setup @getModel()
    editorProxy.editor.transact =>
      runAction action, evt

# Same as `actionDecorator()` but executes action
# with multiple selections
# @param  {Object} action Action to perform
# @return {Function}
multiSelectionActionDecorator = (action) ->
  (evt) ->
    editorProxy.setup(@getModel())
    editorProxy.editor.transact =>
      editorProxy.exec (i) ->
        runAction action, evt
        return false if evt.keyBindingAborted

runAction = (action, evt) ->
  syntax = editorProxy.getSyntax()
  if action is 'expand_abbreviation_with_tab'
    # do not handle Tab key if:
    # -1. syntax is unknown- (no longer valid, defined by keymap selector)
    # 2. there’s a selection (user wants to indent it)
    # 3. has expanded snippet (e.g. has tabstops)
    activeEditor = editorProxy.editor;
    if not isValidTabContext() or not activeEditor.getLastSelection().isEmpty()
      return evt.abortKeyBinding()
    if activeEditor.snippetExpansion
      # in case of snippet expansion: expand abbreviation if we currently on last
      # tabstop
      se = activeEditor.snippetExpansion
      if se.tabStopIndex + 1 >= se.tabStopMarkers.length
        se.destroy()
      else
        return evt.abortKeyBinding()

  if action is 'toggle_comment' and (toggleCommentSyntaxes.indexOf(syntax) is -1 or not atom.config.get 'emmet.useEmmetComments')
    return evt.abortKeyBinding()

  if action is 'insert_formatted_line_break_only'
    if syntax isnt 'html' or not atom.config.get 'emmet.formatLineBreaks'
      return evt.abortKeyBinding()

    result = emmet.run action, editorProxy
    return if not result then evt.abortKeyBinding() else true

  emmet.run action, editorProxy

atomActionName = (name) ->
  'emmet:' + name.replace(/_/g, '-')

registerInteractiveActions = (actions) ->
  for name in ['wrap_with_abbreviation', 'update_tag', 'interactive_expand_abbreviation']
    do (name) ->
      atomAction = atomActionName name
      actions[atomAction] = (evt) ->
        editorProxy.setup(@getModel())
        interactive = require './interactive'
        interactive.run(name, editorProxy)

loadExtensions = () ->
  extPath = atom.config.get 'emmet.extensionsPath'
  console.log 'Loading Emmet extensions from', extPath
  return unless extPath

  if extPath[0] is '~'
    extPath = getUserHome() + extPath.substr 1

  if fs.existsSync extPath
    emmet.resetUserData()
    files = fs.readdirSync extPath
    files = files
      .map((item) -> path.join extPath, item)
      .filter((file) -> not fs.statSync(file).isDirectory())

    emmet.loadExtensions(files)
  else
    console.warn 'Emmet: no such extension folder:', extPath

module.exports =
  config:
    extensionsPath:
      type: 'string'
      default: '~/emmet'
    formatLineBreaks:
      type: 'boolean'
      default: true
    useEmmetComments:
      type: 'boolean'
      default: false
      description: 'disable to use atom native commenting system'

  activate: (@state) ->
    @subscriptions = new CompositeDisposable
    unless @actions
      @subscriptions.add atom.config.observe 'emmet.extensionsPath', loadExtensions
      @actions = {}
      registerInteractiveActions @actions
      for action in emmetActions.getList()
        atomAction = atomActionName action.name
        if @actions[atomAction]?
          continue
        cmd = if singleSelectionActions.indexOf(action.name) isnt -1 then actionDecorator(action.name) else multiSelectionActionDecorator(action.name)
        @actions[atomAction] = cmd

    @subscriptions.add atom.commands.add 'atom-text-editor', @actions

  deactivate: ->
    atom.config.transact => @subscriptions.dispose()
