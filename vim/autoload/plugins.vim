" Initialize minpac and generate the list of packages
"
" Each package should be on a commented line that looks like:
" <name>: <description> plugurl:<repo> [type:<type>] [rev:<rev>] [" comment...]
"
function! plugins#PackInit()
    " Load and initialize minpac
    packadd minpac
    call minpac#init()

    " So I don't need this anywhere else
    call minpac#add('k-takata/minpac', {'type':'opt'})

    " Create the plugin list file
    "
    :enew
    :read $MYVIMRC
    " We definitely want this
    :setlocal noignorecase
    " Delete everything but plugin lines
    :normal zR
    :silent! g!/^".*plugurl:/d
    " Delete 'plugin name, description and 'plugurl:'
    :silent! %s/^".*plugurl://
    " Delete comments
    :silent! %s/\s*".*$//
    " call minpac#add('<plugin repo>', {
    :silent! %s/^\(\S\+\)/call minpac#add('\1', {/
    " Properly quote <key>:<val> pairs
    :silent! %s/\s*\(\w\+\):\(\w\+\)/'\1':'\2',/g
    " Close the option argument
    :silent! %s/$/})/

    " Note that the file should not be edited
    :norm ggI"" Generated file. Do not edit"

    " Write and source the package list
    let pkgfile = '~/.vim/plugins.vim'
    execute 'write! '.pkgfile
    bdelete " in case we run this from an interactive session
    execute 'source '.pkgfile
endfunction

