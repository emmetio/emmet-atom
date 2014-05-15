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

## Default Keybindings

You can change these Preferences > Emmet.

* <kbd>⇥</kbd> / <kbd>⌘E</kbd>:  Expand Abbreviation
* <kbd>⌘⌥⏎</kbd>: Expand Abbreviation (interactive)
* <kbd>⌃W</kbd>: Wrap with Abbreviation
* <kbd>⌃D</kbd>:  Balance (outward)
* <kbd>⌥D</kbd>: Balance (inward)
* <kbd>⌃⌥J</kbd>: Go to Matching Pair
* <kbd>⌃→</kbd>: Next Edit Point
* <kbd>⌃←</kbd>: Previous Edit Point
* <kbd>⌃⇧→</kbd>: Select Next Item
* <kbd>⌃⇧←</kbd>: Select Previous Item
* <kbd>⌘</kbd>/: Toggle Comment
* <kbd>⌘J</kbd>: Split/Join Tag
* <kbd>⌘</kbd>': Remove Tag
* <kbd>⌘Y</kbd>: Evaluate Math Expression
* <kbd>⌃⌥↑</kbd>: Increment Number by 0.1
* <kbd>⌃⌥↓</kbd>: Decrement Number by 0.1
* <kbd>⌃⌥⌘↑</kbd>: Increment Number by 1
* <kbd>⌃⌥⌘↓</kbd>: Decrement Number by 1
* <kbd>⌃⌥⌘⇧↑</kbd>: Increment Number by 10
* <kbd>⌃⌥⌘⇧↓</kbd>: Decrement Number by 10
* <kbd>⌘R</kbd>: Reflect CSS value
* <kbd>⌃I</kbd>: Update Image Size
* <kbd>⌃⇧I</kbd>: Encode/Decode image to data:URL
* <kbd>⌃U</kbd>: Update Tag
* <kbd>⌘M</kbd>: Merge Lines

All actions and their keyboard shortcuts are available under Packages > Emmet menu item.

## Extensions support

You can easily [extend](http://docs.emmet.io/customization/) Emmet with new actions and filters or customize existing ones. In Preferences > Emmet, set Extensions path to folder with Emmet extensions. By default, it’s `~/emmet`, e.g. `emmet` folder in your system HOME folder.