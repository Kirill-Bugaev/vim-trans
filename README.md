# vim-trans
Translation plugin for vim based on [translate-shell][] utility.

## Preamble
For using this plugin you should install [translate-shell][] first.
Archlinux users can do it with `$ pacman -S translate-shell`.
For efficient key maps using you also should set [trans_source] and
[trans_target] options.

### Default key maps
`\t` - translate word under cursor or visually selected.
Translation appears in new window at the bottom of screen which can be closed by `q`
press.

`\bt` - brief translation. Output will be echoed in Vim command line.

## Options

### trans_engine
Translation engine. List of all supported engines can be obtained by
`$ trans -list-engines` shell command.
```vim
let g:trans_engine = 'yandex'
```
(string, default `google`)

### trans_source
Translation source language code. Used for translation by key maps. List of all
available codes can be obtained by `$ trans -reference` shell command.
```vim
let g:trans_source = 'fr'
```
(string, default `en`)

### trans_target
Translation target language code. Used for translation by key maps. List of all
available codes can be obtained by `$ trans -reference` shell command.
```vim
let g:trans_target = 'es'
```
(string, default `ru`)

## Key maps
Key maps can be invoked both for word under cursor and for visually selected text.
If you want to switch off one of key maps define appropriate global variable with empty string value. Example:
```vim
" Switch off key map for brief translation
let g:trans_brief_map = ''
```

### trans_brief_map
Key map for brief translation.
```vim
let g:trans_brief_map = '\bt'
```
(string, default `'\bt'`)

### trans_detailed_map
Key map for detailed translation.
```vim
let g:trans_detailed_map = '\t'
```
(string, default `'\t'`)

## Commands
Actually there is only one command.

### Trans[!] {source-lang-code} {target-lang-code} {text}
Translate {text} from {source-lang-code} language to {target-lang-code} language.
[!] for brief translation.
```vim
:Trans en ru Hello world!
```

[translate-shell]: https://github.com/soimort/translate-shell
