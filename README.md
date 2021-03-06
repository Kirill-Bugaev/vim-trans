# vim-trans
Translation plugin for vim based on [translate-shell][] and
[goldendict][] utilities.

## Preamble
For using this plugin you should install [translate-shell][] or [goldendict][] first.
Archlinux users can do it with `$ pacman -S translate-shell` or
`$ pacman -S goldendict`.
For efficient key maps using you also should set `g:trans_source` and
`g:trans_target` options (only for `g:trans_util = 'translate-shell'`), see below.

### Default key maps
`<leader>t` - translate word under cursor or visually selected.
Translation appears in new window at the bottom of screen which can be closed by `q`
press.

`<leader>bt` - brief translation. Output will be echoed in Vim command line.

## Options

### g:trans_util
Used translation utility.
```vim
let g:trans_util = 'goldendict'
```
(string, default `translate-shell`)

### Options below work only with `g:trans_util = 'translate-shell'`

### trans_engine
Translation engine. List of all supported engines can be obtained by
`$ trans -list-engines` shell command.
```vim
let g:trans_engine = 'yandex'
```
(string, default `google`)

### g:trans_google_api_for_brief
Use Google Translate API for brief translation. It is faster then native
translate-shell engine, but required `wget` utility is installed. Request for
translation is executed with shell and its utilities `sed` and `awk`.
```vim
let g:trans_google_api_for_brief = 1
```
(numeric, default 0)

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

### trans_twice
Make brief translation request twice. Sometimes translation can be obtained faster
if send translation request twice. Works only with `g:trans_google_api_for_brief = 1`.
```vim
let g:trans_twice = 1
```
(string, default `0`)

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
[goldendict]: https://www.goldendict.org
