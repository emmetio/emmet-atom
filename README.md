# Emmet package

[Emmet](http://emmet.io) support for Atom.

## How to get it

```bash
apm install emmet
```

If that doesn't work, try old school:

```bash
cd ~/.atom/packages
git clone https://github.com/atom/emmet
```

## What's working?

Almost everything!

Anything requiring a dialog isn't working. There's no support
(yet) for [_snippets.json_](http://docs.emmet.io/customization/snippets/) and [_preferences.json_](http://docs.emmet.io/customization/preferences/).

## Default Keybindings

You can change these by simply making up your own keybindings in _keymaps/emmet.cson_.

```cson
'meta-E': 'emmet:expand-abbreviation'
'ctrl-d': 'emmet:match-pair-outward'
'alt-d': 'emmet:match-pair-inward'
'ctrl-alt-j': 'emmet:matching-pair'
'ctrl-alt-right': 'emmet:next-edit-point'
'ctrl-alt-left': 'emmet:prev-edit-point'
# 'command+/': 'emmet:toggle_comment' already exists in Atom
'meta-J': 'emmet:split-join-tag'
'meta-K': 'emmet:remove-tag'
'meta-Y': 'emmet:evaluate-math-expression'
'ctrl-shift-up': 'emmet:increment-number-by-1'
'ctrl-shift-down': 'emmet:decrement-number-by-1'
'alt-shift-up': 'emmet:increment-number-by-01'
'alt-shift-down': 'emmet:decrement-number-by-01'
'ctrl-alt-up': 'emmet:increment-number-by-10'
'ctrl-alt-down': 'emmet:decrement-number-by-10'
'alt-meta-.': 'emmet:select-next-item'
'alt-meta-,': 'emmet:select-previous-item'
'meta-R': 'emmet:reflect-css-value'
'ctrl-D': 'emmet:encode-decode-data-url' # decoding doesn't work--we need dialogs
'ctrl-I': 'emmet:update-image-size'
#'ctrl+alt+enter': 'emmet:expand_as_you_type' doesn't work--we need dialogs
# 'shift+ctrl+g': 'emmet:wrap_as_you_type' doesn't work--we need dialogs
# 'Tab': 'emmet:expand_abbreviation_with_tab'
# 'shift+ctrl+a': 'emmet:wrap_with_abbreviation' doesn't work--we need dialogs
```
