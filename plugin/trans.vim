" Brief translation plugin based on translate-shell utility

" Translate options, default values
" Translate engine
if !exists('g:trans_engine')
	let g:trans_engine = 'google'
endif
" Use Google Translate API for brief translation
if !exists('g:trans_google_api_for_brief')
	g:trans_google_api_for_brief = 0
endif
" Source language
if !exists('g:trans_source')
	let g:trans_source = 'en'
endif
" Target language
if !exists('g:trans_target')
	let g:trans_target = 'ru'
endif

" Maps options
" Brief translation
if exists('g:trans_brief_map')
	let s:trans_brief_map = g:trans_brief_map
else
	let s:trans_brief_map = '\bt'
endif
" Detailed translation
if exists('g:trans_detailed_map')
	let s:trans_detailed_map = g:trans_detailed_map
else
	let s:trans_detailed_map = '\t'
endif

" Translation command
command -nargs=* -bang Trans call s:Translate(<bang>0, <f-args>)

" Brief translate flag
let s:brief = 0
" translate-shell output
let s:trans_out = []
" Current job id
"let s:cur_job = Job object 
" Killed job flag
let s:killed = 0

let s:TransBufferName = "TRANS"
let s:TransBufferNumber = -1

" Translate with translate-shell call.
" First arg is source language
" Second arg is target language
" Third arg is pattern
" Bang = 1 for brief translation, direct output to cmd
func s:Translate(bang, ...)
	" Check command syntax
	if len(a:000) < 3
		echom 'trans: not enough arguments. Usage: Trans {source} {target} {pattern}'
		return
	endif

	" Finish previous job if it is not finished yet
	if exists('s:cur_job') && job_status(s:cur_job) == 'run'
		let s:killed = 1
		call job_stop(s:cur_job, 'kill')
	endif
	let s:brief = a:bang
	let s:trans_out = []

	" Replace newline symbols by spaces
	let sp = split(a:000[2], '\n')
	let pattern = join(sp)

	" If user define use Google Translate API for brief translation
	if a:bang && g:trans_google_api_for_brief
		let cmd = ['/bin/sh', '-c',
					\ s:GoogleTranslateAPI_cmd(a:000[0], a:000[1], pattern)]
	else
		" Make shell command expression translate-shell
		" Program name
		let cmd = 'trans'
		" Translation engine
		let cmd .= ' -e ' . g:trans_engine
		" Brief translation
		if a:bang
			let cmd .= ' -b'
		endif
		" Languages
		let cmd .= ' ' . a:000[0] . ':' . a:000[1]
		" Pattern
		let cmd .= ' "' . pattern
		let ind = 3
		while ind < len(a:000)
			let cmd .= ' ' . a:000[ind]
			let ind += 1
		endwhile
		let cmd .= '"'
	endif

	" Run translate-shell asynchronous
	let s:cur_job = job_start(cmd, {'out_cb': function('s:OutCallbackHandler'),
				\ 'exit_cb': function('s:ExitCallbackHandler')})
	echo 'Translating...'
endfunc

" Google Translate API cmd
" Args:	sl - source language, tl - target language, text - text for
" 		translation
" Returns:	cmd for execution with system() or job_start()
func s:GoogleTranslateAPI_cmd(sl, tl, text)
	return 'wget -U "Mozilla/5.0" -qO - "http://translate.googleapis.com/translate_a/single?client=gtx&sl=' . a:sl . '&tl=' . a:tl . '&dt=t&q=$(echo "' . a:text . '" | sed "s/[\"' . "'" . '<>]//g")" | sed "s/,,,0]],,.*//g" | awk -F' . "'" . '"' . "'" . ' ' . "'" . '{ for (i = 2; i <= NF-4; i+=4) print $i }' . "'"
endfunc

" translate-shell output callback handler
func s:OutCallbackHandler(channel, msg)
	" Add output message to list
	let msgs = split(a:msg, "\r")
	for msg in msgs
		call add(s:trans_out, msg)
	endfor
endfunc

" translate-shell exit callback handler
func s:ExitCallbackHandler(job, exit_status)
	" Do nothing if job has been killed
	if s:killed
		let s:killed = 0
		return
	endif

	" If brief translate
	if s:brief 
		" just echo translation in command line
		for msg in s:trans_out
			echom msg
		endfor
	else
		" Create new buffer or use existing for translation output
		" if not brief translation
		if bufloaded(s:TransBufferNumber) != 0
					\ && bufwinnr(s:TransBufferNumber) != -1
			exe bufwinnr(s:TransBufferNumber) . "wincmd w"
"			exe 'bdelete'
			setlocal modifiable
			call deletebufline(s:TransBufferNumber, 1, line('$'))
		else
			exe ":botright new " . s:TransBufferName
			let s:TransBufferNumber = bufnr("%")
			setlocal buftype=nofile
			setlocal noswapfile
			setlocal bufhidden=delete
			setlocal syntax=OFF
			set filetype=man
		endif
		call append(line('$'), s:trans_out)
		setlocal nomodifiable
	endif
endfunc

" Maps
" Brief translation
if s:trans_brief_map != ''
	exe 'nnoremap <silent> ' . s:trans_brief_map
				\ . ' :call <SID>BriefTransOnMap(expand("<cword>"))<CR>'
	exe 'vnoremap <silent> ' . s:trans_brief_map
				\ . ' :call <SID>BriefTransOnMap(<SID>get_visual_selection())<CR>'
endif
" Detailed translation
if s:trans_detailed_map != ''
	exe 'nnoremap <silent> ' . s:trans_detailed_map
				\ . ' :call <SID>DetailedTransOnMap(expand("<cword>"))<CR>'
	exe 'vnoremap <silent> ' . s:trans_detailed_map
				\ . ' :call <SID>DetailedTransOnMap(<SID>get_visual_selection())<CR>'
endif

func s:BriefTransOnMap(text)
"	exe 'Trans! ' . g:trans_source . ' ' . g:trans_target . ' ' . a:text
	call s:Translate(1, g:trans_source, g:trans_target, a:text)
endfunc

func s:DetailedTransOnMap(text)
"	exe 'Trans ' . g:trans_source . ' ' . g:trans_target . ' ' . a:text
	call s:Translate(0, g:trans_source, g:trans_target, a:text)
endfunc

" This function is modified version of written by xolox and published on
" StackOverflow.
" Link: https://stackoverflow.com/questions/1533565/how-to-get-visually-selected-text-in-vimscript
function! s:get_visual_selection()
    if mode()==#"v" || mode()==#"V" || mode()==?"CTRL-V"
        let [line_start, column_start] = getpos("v")[1:2]
        let [line_end, column_end] = getpos(".")[1:2]
    else
        let [line_start, column_start] = getpos("'<")[1:2]
        let [line_end, column_end] = getpos("'>")[1:2]
    end
    if (line2byte(line_start)+column_start) > (line2byte(line_end)+column_end)
        let [line_start, column_start, line_end, column_end] =
        \   [line_end, column_end, line_start, column_start]
    end
    let lines = getline(line_start, line_end)
    if len(lines) == 0
            return ''
    endif
    let lines[-1] = lines[-1][: column_end - 1]
    let lines[0] = lines[0][column_start - 1:]
    return join(lines, "\n")
endfunction
