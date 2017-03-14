" Vim global plugin for selecting the file you actually want to open
" Maintainer: Daniel Schemala <istjanichtzufassen@gmail.com>
" License: MIT


function! s:filter_out_swapfile(matched_files)
    silent! redir => swapfile
        silent swapname
    redir END
    let swapfile = fnamemodify(swapfile[1:], ':p')

    return filter(a:matched_files, 'fnamemodify(v:val, ":p") != swapfile')
endfunction


function! s:didyoumean_bufenter()
    " Specialized function to get notified when opening directories.
    if get(b:, 'didyoumean_done', 0)
        return
    endif
    let b:didyoumean_done = 1
    if !len(expand("%"))
        " Skip handling buffers without name in BufEnter.
        return
    endif
    return s:didyoumean()
endfunction


function! s:didyoumean()
    let fname = expand("%")
    if filereadable(fname)
        " Another BufNewFile event might have handled this already.
        return
    endif
    if isdirectory(fname) && fname[-1:] == '/'
        " A directory is given with an explicit trailing slash - use it.
        return
    endif

    try
        " As of Vim 7.4, glob() has an optional parameter to split, but not
        " everybody is using 7.4 yet
        let matching_files = split(glob(fname."*", 0), '\n')
        if !len(matching_files)
            let matching_files = split(glob(fname."*", 1), '\n')
        endif
        let matching_files = s:filter_out_swapfile(matching_files)
        if len(matching_files) <= 1
            " It might be 1 for directories.
            return
        endif
    catch
        return
    endtry

    let shown_items = ['Did you mean:']
    for i in range(1, len(matching_files))
        call add(shown_items, i.'. '.matching_files[i-1])
    endfor
    let selected_number = inputlist(shown_items)
    if selected_number >= 1 && selected_number <= len(matching_files)
                \ && matching_files[selected_number-1] != fname
        " Load the selected file, but only if it differs from the requested
        " one.  This handles opening directories with netrw/vimfiler etc.
        let empty_buffer_nr = bufnr("%")
        execute ":edit " . fnameescape(matching_files[selected_number-1])
        execute ":silent bdelete " . empty_buffer_nr

        " trigger some autocommands manually which are normally triggered when
        " executing ':edit file', but apparently not here. Don't know why.
        silent doautocmd BufReadPre
        silent doautocmd BufRead
        silent doautocmd BufReadPost
        silent doautocmd TextChanged
    endif
    let b:didyoumean_done = 1
endfunction


autocmd BufNewFile * call s:didyoumean()
autocmd BufEnter * call s:didyoumean_bufenter()
