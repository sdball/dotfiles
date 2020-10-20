""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" BUNDLES
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set nocompatible
filetype off
let g:polyglot_disabled = ['jenkins']
let g:coc_available = 0

" -- Plugins: https://github.com/junegunn/vim-plug ---------------------------
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif
call plug#begin('~/.vim/plugged')

Plug 'AndrewRadev/switch.vim' " plugin to switch segments of text with predefined replacements
" dirty hack for base16
" https://github.com/chriskempson/base16-vim/issues/197
function FixupBase16(info)
  !gsed -i '/Base16hi/\! s/a:\(attr\|guisp\)/l:\1/g' ~/.vim/plugged/base16-vim/colors/*.vim
endfunction
if !empty(glob('~/.config/base16-shell/*'))
  Plug 'chriskempson/base16-vim', { 'do': function('FixupBase16') } " Base16 for Vim with hack
endif
Plug 'conormcd/matchindent.vim' " try to match indent style with the current file
Plug 'dense-analysis/ale'
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
Plug 'jiangmiao/auto-pairs', { 'for': 'rust' } " nice autoinserting matching pairs
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' } " fuzzy finder
Plug 'junegunn/fzf.vim' " fuzzy finder
Plug 'junegunn/vim-easy-align' " align text (search for EasyAlign in vimrc)
if system('uname -m | grep -qv arm') " skip CoC if we're on ARM
  let g:coc_available = 1
  Plug 'neoclide/coc.nvim', {'branch': 'release'}
endif
Plug 'rhysd/clever-f.vim' " smarter f,F,t,T commands
Plug 'sheerun/vim-polyglot' " async language packs
Plug 'tpope/vim-abolish' " substitution with case preservation
Plug 'tpope/vim-commentary' " comment stuff more easily
Plug 'tpope/vim-dispatch' " async build dispatcher
Plug 'tpope/vim-fugitive' " git integration
Plug 'tpope/vim-rhubarb' " GitHub integration
Plug 'tpope/vim-sensible' " sensible defaults
Plug 'tpope/vim-surround' " match matching tags and syntax
Plug 'tpope/vim-unimpaired' " handy bracket mappings
Plug 'wellle/targets.vim' " give vim more targets to operate on
call plug#end()
" -- End Plugins -------------------------------------------------------------

" Machine local setup
if filereadable(expand("~/work/vimrc"))
  source ~/work/vimrc
endif

" Use the system clipboard instead of internal
set clipboard=unnamed

" ALE
let g:ale_fix_on_save = 0
highlight! ALEWarning ctermbg=NONE
highlight! ALEError ctermbg=NONE

" Start interactive EasyAlign in visual mode (e.g. vipga)
xmap ga <Plug>(EasyAlign)

" Start interactive EasyAlign for a motion/text object (e.g. gaip)
nmap ga <Plug>(EasyAlign)

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" BASIC EDITING CONFIGURATION
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" allow unsaved background buffers and remember marks/undo for them
set hidden
" remember more commands and search history
set history=10000
set expandtab
set tabstop=2
set shiftwidth=2
set softtabstop=2
set autoindent
set laststatus=2
set showmatch
set incsearch
set hlsearch
" make searches case-sensitive only if they contain upper-case characters
set ignorecase smartcase
" highlight current line
set cursorline
" more space for messages
set cmdheight=2
set switchbuf=useopen
set numberwidth=1
set number
set showtabline=2
set winwidth=100
set shell=bash
" Prevent Vim from clobbering the scrollback buffer. See
" http://www.shallowsky.com/linux/noaltscreen.html
set t_ti= t_te=
" keep more context when scrolling off the end of a buffer
set scrolloff=3
" No backups
set nobackup
set nowritebackup
" allow backspacing over everything in insert mode
set backspace=indent,eol,start
" display incomplete commands
set showcmd
" Enable highlighting for syntax
syntax on
" Enable file type detection.
" Use the default filetype settings, so that mail gets 'tw' set to 72,
" 'cindent' is on in C files, etc.
" Also load indent files, to automatically do language-dependent indenting.
filetype plugin indent on
" zsh-style completion
set wildmode=full
" make tab completion for files/buffers act like bash
set wildmenu

if g:coc_available
  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  " COC settings
  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

  " (in ms) default is 4000ms
  set updatetime=300

  " Don't pass messages to |ins-completion-menu|.
  set shortmess+=c

  " Always show the signcolumn, otherwise it would shift the text each time
  " diagnostics appear/become resolved.
  set signcolumn=yes

  " Use tab for trigger completion with characters ahead and navigate.
  " NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
  " other plugin before putting this into your config.
  inoremap <silent><expr> <TAB>
        \ pumvisible() ? "\<C-n>" :
        \ <SID>check_back_space() ? "\<TAB>" :
        \ coc#refresh()
  inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

  function! s:check_back_space() abort
    let col = col('.') - 1
    return !col || getline('.')[col - 1]  =~# '\s'
  endfunction

  " Use <c-space> to trigger completion.
  inoremap <silent><expr> <c-space> coc#refresh()

  " Use <cr> to confirm completion, `<C-g>u` means break undo chain at current
  " position. Coc only does snippet and additional edit on confirm.
  if exists('*complete_info')
    inoremap <expr> <cr> complete_info()["selected"] != "-1" ? "\<C-y>" : "\<C-g>u\<CR>"
  else
    imap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
  endif

  " Use `[g` and `]g` to navigate diagnostics
  nmap <silent> [g <Plug>(coc-diagnostic-prev)
  nmap <silent> ]g <Plug>(coc-diagnostic-next)

  " GoTo code navigation.
  nmap <silent> gd <Plug>(coc-definition)
  nmap <silent> gy <Plug>(coc-type-definition)
  nmap <silent> gi <Plug>(coc-implementation)
  nmap <silent> gr <Plug>(coc-references)

  " Use K to show documentation in preview window.
  nnoremap <silent> K :call <SID>show_documentation()<CR>

  function! s:show_documentation()
    if (index(['vim','help'], &filetype) >= 0)
      execute 'h '.expand('<cword>')
    else
      call CocAction('doHover')
    endif
  endfunction

  " Highlight the symbol and its references when holding the cursor.
  autocmd CursorHold * silent call CocActionAsync('highlight')

  " Symbol renaming.
  nmap <leader>rn <Plug>(coc-rename)

  " Formatting selected code.
  xmap <leader>f  <Plug>(coc-format-selected)
  nmap <leader>f  <Plug>(coc-format-selected)

  augroup mygroup
    autocmd!
    " Setup formatexpr specified filetype(s).
    autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
    " Update signature help on jump placeholder.
    autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
  augroup end

  " Applying codeAction to the selected region.
  " Example: `<leader>aap` for current paragraph
  xmap <leader>a  <Plug>(coc-codeaction-selected)
  nmap <leader>a  <Plug>(coc-codeaction-selected)

  " Remap keys for applying codeAction to the current line.
  nmap <leader>ac  <Plug>(coc-codeaction)
  " Apply AutoFix to problem on the current line.
  nmap <leader>qf  <Plug>(coc-fix-current)

  " Introduce function text object
  " NOTE: Requires 'textDocument.documentSymbol' support from the language server.
  xmap if <Plug>(coc-funcobj-i)
  xmap af <Plug>(coc-funcobj-a)
  omap if <Plug>(coc-funcobj-i)
  omap af <Plug>(coc-funcobj-a)

  " Use <TAB> for selections ranges.
  " NOTE: Requires 'textDocument/selectionRange' support from the language server.
  " coc-tsserver, coc-python are the examples of servers that support it.
  nmap <silent> <TAB> <Plug>(coc-range-select)
  xmap <silent> <TAB> <Plug>(coc-range-select)

  " Add `:Format` command to format current buffer.
  command! -nargs=0 Format :call CocAction('format')

  " Add `:Fold` command to fold current buffer.
  command! -nargs=? Fold :call     CocAction('fold', <f-args>)

  " Add `:OR` command for organize imports of the current buffer.
  command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')

  " Add (Neo)Vim's native statusline support.
  " NOTE: Please see `:h coc-status` for integrations with external plugins that
  " provide custom statusline: lightline.vim, vim-airline.
  set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

  " Mappings using CoCList:
  " Show all diagnostics.
  nnoremap <silent> <space>a  :<C-u>CocList diagnostics<cr>
  " Manage extensions.
  nnoremap <silent> <space>e  :<C-u>CocList extensions<cr>
  " Show commands.
  nnoremap <silent> <space>c  :<C-u>CocList commands<cr>
  " Find symbol of current document.
  nnoremap <silent> <space>o  :<C-u>CocList outline<cr>
  " Search workspace symbols.
  nnoremap <silent> <space>s  :<C-u>CocList -I symbols<cr>
  " Do default action for next item.
  nnoremap <silent> <space>j  :<C-u>CocNext<CR>
  " Do default action for previous item.
  nnoremap <silent> <space>k  :<C-u>CocPrev<CR>
  " Resume latest coc list.
  nnoremap <silent> <space>p  :<C-u>CocListResume<CR>
endif

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" CUSTOM AUTOCMDS
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
augroup vimrcEx
  " Clear all autocmds in the group
  autocmd!
  autocmd FileType text setlocal textwidth=78
  " Jump to last cursor position unless it's invalid or in an event handler
  autocmd BufReadPost *
    \ if line("'\"") > 0 && line("'\"") <= line("$") |
    \   exe "normal g`\"" |
    \ endif

  " spaces
  autocmd FileType ruby,haml,eruby,yaml,toml,html,sh set ai sw=2 sts=2 et

  " python autocmds
  autocmd FileType python set sw=4 sts=4 et
  autocmd FileType python let t:command="python -m pytest -s"
  autocmd FileType python let t:all_command="python -m pytest -s"
  autocmd FileType python map <leader>2 :wall\|:!python2 -m pytest -s %<cr>
  autocmd FileType python map <leader>3 :wall\|:!python3 -m pytest -s %<cr>
  autocmd FileType python let t:style_command="black \"%\""

  " javascript autocmds
  autocmd FileType javascript set ai sw=2 sts=2 et
  autocmd FileType javascript let t:command="npm test"

  " shell autocmds
  autocmd FileType sh let t:style_command="shellcheck --shell=bash --exclude=SC2164,SC2001 \"%\""
  autocmd FileType sh map <leader>r :wall\|:!./%<cr>

  autocmd FileType ruby map <leader>r :wall\|:!ruby %<cr>

  autocmd FileType go set sw=2 ts=2 sts=2 noet

  if filereadable(expand("~/work/autocmds.vim"))
    source ~/work/autocmds.vim
  endif
augroup END

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" COLOR
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

if filereadable(expand("~/.vimrc_background"))
  if has("termguicolors")
    set termguicolors
  endif
  let base16colorspace=256
  source ~/.vimrc_background
  map <F5> :source ~/.vimrc_background<CR>
else
  colorscheme default
endif

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" STATUS LINE
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
:set statusline=%<%f\ (%{&ft})\ %-4(%m%)%=%-19(%3l,%02c%03V%)

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" just a bit of cartography
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let mapleader=","

" Fix linting errors
map <leader>f :ALEFix<cr>

" Store a session
map <leader>m :mksession! /tmp/vim-session<cr>\|:wqall<cr>

" Yank a movement
map <leader>y "*y

" Move around splits with <c-hjkl>
nnoremap <c-j> <c-w>j
nnoremap <c-k> <c-w>k
nnoremap <c-h> <c-w>h
nnoremap <c-l> <c-w>l

" some frequent code inserts
imap <c-l> <space>=><space>

" insert current datetime
imap <c-d> # <c-R>=strftime("%Y-%m-%d %A")<cr>

" Can't be bothered to understand ESC vs <c-c> in insert mode
imap <c-c> <esc>

" Clear the search buffer when hitting return
:nnoremap <CR> :nohlsearch<cr>

" Jump to previous file
nnoremap <leader><leader> <c-^>

" open files in directory of current file
cnoremap %% <C-R>=expand('%:h').'/'<cr>
map <leader>e :edit %%

" map to current file for command mode
cnoremap $$ <C-R>=expand('%')<cr>

" TESTING, WOO!
nnoremap <leader>. :call OpenTestAlternate()<cr>
map <leader>t :call RunTestFile()<cr>
map <leader>T :call RunNearestTest()<cr>
map <leader>a :call RunAllTests()<cr>
map <leader>s :call RunStyleChecks()<cr>

" when nested too deep
nnoremap <leader>x :set cursorcolumn!<cr>

" toggle numbers
map <leader># :set number!<cr>

" :W should really be :w because I never want :W and always mean :w
" :Q should really be :q because Q doesn't even do anything
" put them together and magic
command WQ wq
command Wq wq
command W w
command Q q

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" PASTE MODE SANITY
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set pastetoggle=<leader>v
set showmode

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" BIG RED UNWANTED WHITESPACE
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
highlight ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /(\s\+$|\t)/
autocmd BufWinEnter * match ExtraWhitespace /\s\+$/
autocmd InsertEnter * match ExtraWhitespace /\s\+\%#\@<!$/
autocmd InsertLeave * match ExtraWhitespace /\s\+$/
autocmd BufWinLeave * call clearmatches()

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" RUNNING TESTS AND STYLE
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! RunStyleChecks()
  if !exists("t:style_command")
    echo "Unknown global style check command"
  else
    exec ":!" . t:style_command
  end
endfunction
function! RunAllTests()
  if !exists("t:all_command")
    echo "Unknown global test suite command"
  else
    exec ":!" . t:all_command
  end
endfunction
function! RunTestFile(...)
    if a:0
        let command_suffix = a:1
    else
        let command_suffix = ""
    endif

" Run the tests for the previously-marked file.
    let in_test_file = match(expand("%"), '\(.feature\|_spec.rb\|-spec.rb\|_test.rb\|_test.exs\|spec.js\|spec.ts\|test.ts\|_test.py\)$\|test_.*\.py$') != -1
    if in_test_file
        if exists("t:sdb_marked_test")
          unlet t:sdb_marked_test
        end
        echo "IN TEST FILE"
        call SetTestFile()
    elseif !exists("t:sdb_test_file_path")
        echo "Not in test file and no marked test file"
        return
    end

    call RunTests(t:sdb_test_file_path, command_suffix)
endfunction

function! RunNearestTest()
    let spec_line_number = line('.')
    call RunTestFile(spec_line_number)
endfunction

function! SetTestFile()
" Set the spec file that tests will be run for.
    let t:sdb_test_file_path=@%
    let t:sdb_test_file_name=expand("%:t")
    let t:sdb_test_file_fullpath=expand("%:p")
endfunction

function! RunTests(filename, line_number)
    " Write the open files and run tests for the given filename
    :wall
    if a:filename =~ "\.rb$"
        if a:filename =~ "spec"
            if filereadable("Gemfile")
                let command="bundle exec rspec"
            else
                let command="ruby"
            end

            if a:line_number
                exec ":!" . command . " " . a:filename . ":" . a:line_number
            else
                exec ":!" . command . " " . a:filename
            end
        else
            if filereadable("Gemfile")
                let command="bundle exec ruby"
            else
                let command="ruby"
            end

            if a:line_number
                let test_name=system("head -n " . a:line_number . " " . a:filename . " | rg '(def test_|test \")' | tail -1 | sed -e 's/.*def //' -e 's/.*test //' -e 's/ do$//' | tr '\"' / | tr \"'\" / | tr ' ' _")
                exec ":!" . command . " -Itest " . a:filename . " -n " . test_name
            else
                exec ":!" . command . " -Itest " . a:filename
            end
        end
    elseif a:filename =~ "\.exs$"
        if filereadable("mix.exs")
            let command="mix test"

            if a:line_number
                exec ":!" . command . " " . a:filename . ":" . a:line_number
            else
                exec ":!" . command . " " . a:filename
            end
        else
            let command="elixir"
            exec ":!" . command . " " . a:filename
        end
    elseif a:filename =~ "\.[jt]s$"
      if exists("t:direct_command") && t:direct_command
        exec ":!" . t:command . " " . t:sdb_test_file_fullpath
        return
      end
      " Jest
      :silent !command -v node_modules/.bin/jest >/dev/null
      if v:shell_error == 0
        echo "JEST"
        let command="node_modules/.bin/jest --color"
        exec ":!" . command . " " . '"' . t:sdb_test_file_fullpath . '"'
      else
        :silent !command -v jasmine >/dev/null
        if v:shell_error == 0
          echo "JASMINE"
          " Jasmine
          let current_file=expand('%')
          if a:line_number && current_file == a:filename
            " run the specific test containing the selected line by
            " - finding the relevant it or describe declaration
            " - changing it to fit or fdescribe
            " - running the filtered test file
            " - reverting the fit/fdescribe back to it/describe
            normal j
            ?\(\(^\|\s\)it\|\(^\|\s\)describe\)
            normal If
            :silent w
            let basename=system("echo -n `basename " . a:filename . "`")
            exec ':!' . t:command . ' --filter="\"' . basename . '\""'
            normal x
            :silent w
          else
            if exists("t:direct_command") && t:direct_command
              if exists("t:strip_from_testfile")
                let b:filename = substitute(a:filename, t:strip_from_testfile, '', '')
              else
                let b:filename = a:filename
              end
              echo b:filename
              if exists("t:post_command")
                exec ':!' . t:command . '"' . b:filename . '"' . t:post_command
              else
                exec ':!' . t:command . ' "' . b:filename . '"'
              end
            else
              if exists("t:use_dirname") && t:use_dirname
                let filter=system("echo -n $(dirname \"" . a:filename . "\" | sed -e 's|" . t:strip_from_dirname . "||')")
              else
                let filter=system("echo -n `basename \"" . a:filename . "\"`")
              end
              exec ':!' . t:command . ' --filter="\"' . filter . '\""'
            end
          end
        else
          echo "UNKNOWN"
        end
      end
    elseif a:filename =~ "\.py$"
      if exists("t:sdb_marked_test")
        exec ":!" . t:command . " -k " . t:sdb_marked_test
      elseif a:line_number
        let test_name=system("head -n " . a:line_number . " " . a:filename . " | rg -o '(def test.*|class Test.*)' | tail -1 | sed -e 's/^def //' -e 's/^class //' -e s'/[(:].*$//'")
        let t:sdb_marked_test=test_name
        exec ":!" . t:command . " -k " . test_name
      else
        exec ':!' . t:command . ' ' . a:filename
      end
    else
      exec ':!' . t:command . ' ' . a:filename
    end
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" FZF                                                                        "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" --column: Show column number
" --line-number: Show line number
" --no-heading: Do not show file headings in results
" --fixed-strings: Search term as a literal string
" --ignore-case: Case insensitive search
" --no-ignore: Do not respect .gitignore, etc...
" --hidden: Search hidden files and folders
" --follow: Follow symlinks
" --glob: Additional conditions for search (in this case ignore everything in the .git/ folder)
" --color: Search color options
command! -bang -nargs=* Rg
  \ call fzf#vim#grep(
  \   'rg --column --line-number --no-heading --color=always '.shellescape(<q-args>), 1,
  \   <bang>0 ? fzf#vim#with_preview('up:60%')
  \           : fzf#vim#with_preview('right:50%:hidden', '?'),
  \   <bang>0)

let g:fzf_commits_log_options = '--graph --color=always --format="%C(auto)%h | %<(20,trunc)%an | %s"'

map <C-t> :GFiles<cr>
map <C-p> :Files<cr>
map <C-g> :Rg<cr>
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" REVEAL
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! SetupReveal()
    let t:sdb_reveal_file="outline.txt"
    let t:sdb_reveal_line=0
endfunction

function! Reveal()
    :normal 1GdG
    let t:sdb_reveal_line=t:sdb_reveal_line + 1
    exec ":read !head -" . t:sdb_reveal_line . " " . t:sdb_reveal_file
    :normal gg
    :normal dd
endfunction
