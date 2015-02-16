# Emmet plugin Atom editor

[Emmet](http://emmet.io) support for [Atom](http://atom.io).

## Installation

In Atom, open Preferences > Packages, search for `Emmet` package. Once it found, click `Install` button to install package.

### Manual installation

You can install the latest Emmet version manually from console:

```bash
cd ~/.atom/packages
git clone https://github.com/emmetio/emmet-atom
cd emmet-atom
npm install
```

Then restart Atom editor.

## Features:

* Expand abbreviations by <kbd>Tab</kbd> key.
* Multiple cursor support: most [Emmet actions](http://docs.emmet.io/actions/) like Expand Abbreviation, Wrap with Abbreviation, Update Tag can run in multi-cursor mode.
* Interactive actions (Interactive Expand Abbreviation, Wrap With Abbreviation, Update Tag) allows you to preview result real-time as you type.
* Better tabstops in generated content: when abbreviation expanded, hit <kbd>Tab</kbd> key to quickly traverse between important code points.
* [Emmet v1.1 core](http://emmet.io/blog/beta-v1-1/).

Please report any problems at [issue tracker](https://github.com/emmetio/emmet-atom/issues).

## Tab key

Currently, Emmet expands abbreviations by Tab key only for HTML, CSS, Sass/SCSS and LESS syntaxes. Tab handler scope is limited because it overrides default snippets.

If you want to make Emmet expand abbreviations with Tab key for other syntaxes, you can do the following:

1. Use *Open Your Keymap* menu item to open your custom `keymap.cson` file.
2. Add the following section into it:

```coffee
'atom-text-editor[data-grammar="YOUR GRAMMAR HERE"]:not([mini])':
    'tab': 'emmet:expand-abbreviation-with-tab'
```

Replace `YOUR GRAMMAR HERE` with actual grammar attribute value. The easiest way to get grammar name of currently opened editor is to open DevTools and find corresponding `<atom-text-editor>` element: it will contain `data-grammar` attribute with value you need. For example, for HTML syntax it’s a `text html basic`.

You can add as many sections as you like for different syntaxes. Note that default snippets will no longer work, but you can add [your own snippets in Emmet](http://docs.emmet.io/customization/).

## Default Keybindings

You can change these Preferences > Emmet.

Command | Darwin | Linux/Windows
------- | ------ | -------------
Expand Abbreviation | <kbd>tab</kbd> or <kbd>shift</kbd> + <kbd>⌘</kbd> + <kbd>e</kbd> | <kbd>tab</kbd> or <kbd>ctrl</kbd> + <kbd>e</kbd>
Expand Abbreviation (interactive) | <kbd>alt</kbd> + <kbd>⌘</kbd> + <kbd>enter</kbd> | <kbd>ctrl</kbd> + <kbd>alt</kbd> + <kbd>enter</kbd>
Wrap with Abbreviation | <kbd>ctrl</kbd> + <kbd>w</kbd> | <kbd>ctrl</kbd> + <kbd>alt</kbd> + <kbd>w</kbd>
Balance (outward) | <kbd>ctrl</kbd> + <kbd>d</kbd> | <kbd>ctrl</kbd> + <kbd>,</kbd>
Balance (inward) | <kbd>alt</kbd> + <kbd>d</kbd> | <kbd>ctrl</kbd> + <kbd>shift</kbd> + <kbd>0</kbd>
Go to Matching Pair | <kbd>ctrl</kbd> + <kbd>alt</kbd> + <kbd>j</kbd> | <kbd>ctrl</kbd> + <kbd>alt</kbd> + <kbd>j</kbd>
Next Edit Point | <kbd>ctrl</kbd> + <kbd>→</kbd> | <kbd>ctrl</kbd> + <kbd>alt</kbd> + <kbd>→</kbd>
Previous Edit Point | <kbd>ctrl</kbd> + <kbd>←</kbd> | <kbd>ctrl</kbd> + <kbd>alt</kbd> + <kbd>←</kbd>
Select Next Item | <kbd>ctrl</kbd> + <kbd>shift</kbd> + <kbd>→</kbd> | <kbd>ctrl</kbd> + <kbd>shift</kbd> + <kbd>.</kbd>
Select Previous Item | <kbd>ctrl</kbd> + <kbd>shift</kbd> + <kbd>←</kbd> | <kbd>ctrl</kbd> + <kbd>shift</kbd> + <kbd>,</kbd>
Toggle Comment | <kbd>⌘</kbd> + <kbd>/</kbd> | <kbd>ctrl</kbd> + <kbd>shift</kbd> + <kbd>/</kbd>
Split/Join Tag | <kbd>shift</kbd> + <kbd>⌘</kbd> + <kbd>j</kbd> | <kbd>ctrl</kbd> + <kbd>shift</kbd> + <kbd>`</kbd>
Remove Tag | <kbd>⌘</kbd> + <kbd>'</kbd> | <kbd>ctrl</kbd> + <kbd>shift</kbd> + <kbd>;</kbd>
Evaluate Math Expression | <kbd>shift</kbd> + <kbd>⌘</kbd> + <kbd>y</kbd> | <kbd>ctrl</kbd> + <kbd>shift</kbd> + <kbd>y</kbd>
Increment Number by 0.1 | <kbd>ctrl</kbd> + <kbd>alt</kbd> + <kbd>↑</kbd> | <kbd>alt</kbd> + <kbd>↑</kbd>
Decrement Number by 0.1 | <kbd>ctrl</kbd> + <kbd>alt</kbd> + <kbd>↓</kbd> | <kbd>alt</kbd> + <kbd>↓</kbd>
Increment Number by 1 | <kbd>ctrl</kbd> + <kbd>alt</kbd> + <kbd>⌘</kbd> + <kbd>↑</kbd> | <kbd>ctrl</kbd> + <kbd>↑</kbd>
Decrement Number by 1 | <kbd>ctrl</kbd> + <kbd>alt</kbd> + <kbd>⌘</kbd> + <kbd>↓</kbd> | <kbd>ctrl</kbd> + <kbd>↓</kbd>
Increment Number by 10 | <kbd>ctrl</kbd> + <kbd>alt</kbd> + <kbd>⌘</kbd> + <kbd>shift</kbd> + <kbd>↑</kbd> | <kbd>shift</kbd> + <kbd>alt</kbd> + <kbd>↑</kbd>
Decrement Number by 10 | <kbd>ctrl</kbd> + <kbd>alt</kbd> + <kbd>⌘</kbd> + <kbd>shift</kbd> + <kbd>↓</kbd> | <kbd>shift</kbd> + <kbd>alt</kbd> + <kbd>↓</kbd>
Reflect CSS value | <kbd>shift</kbd> + <kbd>⌘</kbd> + <kbd>r</kbd> | <kbd>ctrl</kbd> + <kbd>shift</kbd> + <kbd>r</kbd>
Update Image Size | <kbd>ctrl</kbd> + <kbd>i</kbd> | <kbd>ctrl</kbd> + <kbd>u</kbd>
Encode/Decode image to data:URL | <kbd>ctrl</kbd> + <kbd>shift</kbd> + <kbd>i</kbd> | <kbd>ctrl</kbd> + <kbd>'</kbd>
Update Tag | <kbd>ctrl</kbd> + <kbd>shift</kbd> + <kbd>u</kbd> | <kbd>ctrl</kbd> + <kbd>shift</kbd> + <kbd>'</kbd>
Merge Lines | <kbd>shift</kbd> + <kbd>⌘</kbd> + <kbd>m</kbd> | <kbd>ctrl</kbd> + <kbd>shift</kbd> + <kbd>m</kbd>

All actions and their keyboard shortcuts are available under Packages > Emmet menu item.

## Extensions support

You can easily [extend](http://docs.emmet.io/customization/) Emmet with new actions and filters or customize existing ones. In Preferences > Emmet, set Extensions path to folder with Emmet extensions. By default, it’s `~/emmet`, e.g. `emmet` folder in your system HOME folder.
