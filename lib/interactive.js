/**
 * Definition of interactive functions: the function
 * that require additional dialog prompt and update
 * editor content when user types data in prompt
 */
var utils       = require('emmet/lib/utils/common');
var editorUtils = require('emmet/lib/utils/editor');
var actionUtils = require('emmet/lib/utils/action');

var range       = require('emmet/lib/assets/range');
var htmlMatcher = require('emmet/lib/assets/htmlMatcher');
var parser      = require('emmet/lib/parser/abbreviation');
var updateTag   = require('emmet/lib/action/updateTag');

var atom = require('atom');
var PromptView = require('./prompt');
var Point = atom.Point;
var Range = atom.Range;
var prompt = new PromptView();

/**
 * Caches wrapping context for current selection in editor
 * @param  {IEmmetEditor} editor 
 * @param  {Object} info Current editor info (content, syntax, etc.) 
 * @return {Object}
 */
function selectionContext(editor, info) {
	info = info || editorUtils.outputInfo(editor);
	return editor.selectionList().map(function(sel, i) {
		var r = range(sel);
		var tag = htmlMatcher.tag(info.content, r.start);
		if (!r.length() && tag) {
			// no selection, use tag pair
			r = utils.narrowToNonSpace(info.content, tag.range);
		}

		var out = {
			selection: r,
			tag: tag,
			caret: r.start,
			syntax: info.syntax,
			profile: info.profile || null,
			counter: i + 1,
			contextNode: actionUtils.captureContext(editor, r.start)
		};

		if (r.length()) {
			var pasted = utils.escapeText(r.substring(info.content));
			out.pastedContent = editorUtils.unindent(editor, pasted);
		}

		return out;
	});
}

function updateFinalCarets(selCtx, fromIndex, delta) {
	if (!delta) {
		return;
	}

	var offset = new Point(delta, 0);
	for (var i = fromIndex + 1, il = selCtx.length; i < il; i++) {
		selCtx[i].finalCaret = selCtx[i].finalCaret.translate(offset);
	}
}

/**
 * Returns current caret position for given editor
 * @param  {Editor} editor Atom editor instance
 * @return {Number}        Character index in editor
 */
function getCaret(editor) {
	// we can’t use default `getCursor()` method because it returns
	// the most recent (e.g. the latest) caret, but we need the first one
	return editor.getSelectedBufferRanges()[0].start;
}

function lineDelta(prev, cur) {
	return utils.splitByLines(cur).length - utils.splitByLines(prev).length;
}

function setFinalCarets(selCtx, editor) {
	if (selCtx && selCtx.length > 1) {
		editor.setSelectedBufferRanges(selCtx.map(function(ctx) {
			return new Range(ctx.finalCaret, ctx.finalCaret);
		}));
	}
}

module.exports = {
	run: function(cmd, editor) {
		if (cmd === 'wrap_with_abbreviation') {
			return this.wrapWithAbbreviation(editor);
		}

		if (cmd === 'update_tag') {
			return this.updateTag(editor);
		}

		if (cmd === 'interactive_expand_abbreviation') {
			return this.expandAbbreviation(editor);
		}
	},

	expandAbbreviation: function(editor) {
		var info = editorUtils.outputInfo(editor);
		var selCtx = editor.selectionList().map(function(sel, i) {
			editor._selection.index = i;
			var r = range(sel);
			return {
				selection: r,
				selectedText: r.substring(info.content),
				caret: r.start,
				syntax: info.syntax,
				profile: info.profile || null,
				counter: i + 1,
				contextNode: actionUtils.captureContext(editor, r.start)
			};
		});

		return this.wrapWithAbbreviation(editor, selCtx);
	},

	wrapWithAbbreviation: function(editor, selCtx) {
		selCtx = selCtx || selectionContext(editor);

		// show prompt dialog that will wrap each selection
		// on user typing
		prompt.show({
			label: 'Enter Abbreviation',
			editor: editor.editor,
			editorView: editor.editorView,
			update: function(abbr) {
				var result, replaced;
				for (var i = selCtx.length - 1, ctx; i >= 0; i--) {
					ctx = selCtx[i];
					result = '';
					try {
						if (abbr) {
							result = parser.expand(abbr, ctx);
						} else {
							result = ctx.pastedContent;
						}
					} catch (e) {
						console.error(e);
						result = ctx.pastedContent;
					}

					editor._selection.index = i;
					replaced = editor.replaceContent(result, ctx.selection.start, ctx.selection.end);
					ctx.finalCaret = getCaret(editor.editor);
					updateFinalCarets(selCtx, i, lineDelta(ctx.selectedText, replaced));
				}
			},
			confirm: function() {
				setFinalCarets(selCtx, editor.editor);
			}
		});
	},

	updateTag: function(editor) {
		var info = editorUtils.outputInfo(editor);
		var selCtx = selectionContext(editor, info);

		// show prompt dialog that will update each
		// tag from selection
		prompt.show({
			label: 'Enter Abbreviation',
			editor: editor.editor,
			editorView: editor.editorView,
			update: function(abbr) {
				var tag, replaced, delta;
				for (var i = selCtx.length - 1, ctx; i >= 0; i--) {
					ctx = selCtx[i];
					tag = null;

					try {
						tag = updateTag.getUpdatedTag(abbr, {match: ctx.tag}, info.content, {
							counter: ctx.counter
						});
					} catch (e) {
						console.error(e);
					}

					if (!tag) {
						continue;
					}

					replaced = [{
						start: ctx.tag.open.range.start, 
						end: ctx.tag.open.range.end,
						content: tag.source
					}];

					if (tag.name() != ctx.tag.name && ctx.tag.close) {
						replaced.unshift({
							start: ctx.tag.close.range.start, 
							end: ctx.tag.close.range.end,
							content: '</' + tag.name() + '>'
						});
					}

					replaced.forEach(function(data) {
						editor.replaceContent(data.content, data.start, data.end);
						ctx.finalCaret = editor.editor.getBuffer().positionForCharacterIndex(data.start);
					});
				}

			},
			confirm: function() {
				setFinalCarets(selCtx, editor.editor);
			}
		});
	}
};