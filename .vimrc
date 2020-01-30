""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" BUNDLES
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set nocompatible
filetype off

" -- Plugins: https://github.com/junegunn/vim-plug ---------------------------
call plug#begin('~/.vim/plugged')

Plug 'AndrewRadev/switch.vim' " plugin to switch segments of text with predefined replacements
" dirty hack for base16
" https://github.com/chriskempson/base16-vim/issues/197
function FixupBase16(info)
  !gsed -i '/Base16hi/\! s/a:\(attr\|guisp\)/l:\1/g' ~/.vim/plugged/base16-vim/colors/*.vim
endfunction
Plug 'chriskempson/base16-vim', { 'do': function('FixupBase16') } " Base16 for Vim with hack
Plug 'conormcd/matchindent.vim' " try to match indent style with the current file
Plug 'ervandew/supertab' " insert mode tab completions against open buffers
Plug 'jiangmiao/auto-pairs', { 'for': 'rust' } " nice autoinserting matching pairs
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' } " fuzzy finder
Plug 'junegunn/fzf.vim' " fuzzy finder
Plug 'rhysd/clever-f.vim' " smarter f,F,t,T commands
Plug 'sheerun/vim-polyglot' " async language packs
Plug 'terryma/vim-multiple-cursors' " multiple cursor selections
Plug 'tpope/vim-commentary' " comment stuff more easily
Plug 'tpope/vim-dispatch' " async build dispatcher
Plug 'tpope/vim-fugitive' " git integration
Plug 'tpope/vim-rhubarb' " GitHub integration
Plug 'tpope/vim-sensible' " sensible defaults
Plug 'tpope/vim-surround' " match matching tags and syntax
Plug 'tpope/vim-unimpaired' " handy bracket mappings
Plug 'wellle/targets.vim' " give vim more targets to operate on
Plug 'junegunn/vim-easy-align'

call plug#end()
" -- End Plugins -------------------------------------------------------------

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
" Store temporary files in a central spot
set backup
set backupdir=~/.vim-tmp,~/.tmp,~/tmp,/var/tmp,/tmp
set directory=~/.vim-tmp,~/.tmp,~/tmp,/var/tmp,/tmp
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

  " rust autocmds
  autocmd FileType rust set ai sw=4 sts=4 et
  autocmd FileType rust map <leader>s :RustFmt<cr>
  autocmd FileType rust imap <c-d> #[derive()]<ESC>hi
  autocmd FileType rust imap <c-a> #![allow()]<ESC>hi
  autocmd FileType rust imap <c-f> fn ()<ESC>hha
  autocmd FileType rust imap <c-p> println!("");<ESC>hhi
  autocmd FileType rust imap <c-e> {}
  autocmd FileType rust imap <c-r> {:?}
  autocmd FileType rust imap <s-tab> fn main() {<CR>}<ESC>O
  if filereadable("Cargo.toml")
    autocmd FileType rust map <leader>r :wall\|:!cargo run<cr>
    autocmd FileType rust map <leader>t :wall\|:!cargo test -- --color always --nocapture<cr>
  else
    autocmd FileType rust map <leader>r :wall\|:!rustc % && ./%:r<cr>
  endif
  autocmd FileType ruby map <leader>r :wall\|:!ruby %<cr>

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
  colorscheme base16-ashes
endif

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" STATUS LINE
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
:set statusline=%<%f\ (%{&ft})\ %-4(%m%)%=%-19(%3l,%02c%03V%)

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" just a bit of cartography
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let mapleader=","

" Store a session
map <leader>m :mksession! /tmp/vim-session<cr> :wqall<cr>

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

" misc
inoremap <tab> <c-r>=InsertTabWrapper()<cr>

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
    let in_test_file = match(expand("%"), '\(.feature\|_spec.rb\|-spec.rb\|_test.rb\|_test.exs\|spec.js\|_test.py\)$\|test_.*\.py$') != -1
    if in_test_file
        echo "IN TEST FILE"
        call SetTestFile()
    elseif !exists("t:sdb_test_file")
        return
    end

    call RunTests(t:sdb_test_file, command_suffix)
endfunction

function! RunNearestTest()
    let spec_line_number = line('.')
    call RunTestFile(spec_line_number)
endfunction

function! SetTestFile()
" Set the spec file that tests will be run for.
    let t:sdb_test_file=@%
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
    elseif a:filename =~ "\.js$"
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
        if t:direct_command
          let b:filename = substitute(a:filename, t:strip_from_testfile, '', '')
          echo b:filename
          exec ':!' . t:command . '"' . b:filename . '"' . t:post_command
        else
          if t:use_dirname
            let filter=system("echo -n $(dirname \"" . a:filename . "\" | sed -e 's|" . t:strip_from_dirname . "||')")
          else
            let filter=system("echo -n `basename \"" . a:filename . "\"`")
          end
          exec ':!' . t:command . ' --filter="\"' . filter . '\""'
        end
      end
    elseif a:filename =~ "\.py$"
      if a:line_number
        let test_name=system("head -n " . a:line_number . " " . a:filename . " | rg -o '(def test.*|class test.*)' | tail -1 | sed -e 's/^def //' -e 's/^class //' -e s'/[(:].*$//'")
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
map <C-g> :Ag<cr>
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

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" JavaScript Business
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:javascript_conceal_function             = "ƒ"
let g:javascript_conceal_null                 = "ø"
let g:javascript_conceal_this                 = "@"
let g:javascript_conceal_return               = "⇚"
let g:javascript_conceal_undefined            = "¿"
let g:javascript_conceal_NaN                  = "ℕ"
let g:javascript_conceal_prototype            = "¶"
let g:javascript_conceal_static               = "•"
let g:javascript_conceal_super                = "Ω"
let g:javascript_conceal_arrow_function       = "⇒"
" let g:javascript_conceal_noarg_arrow_function = "🞅"
" let g:javascript_conceal_underscore_arrow_function = "🞅"
map <leader>c :exec &conceallevel ? "set conceallevel=0" : "set conceallevel=1"<CR>


let s:hidden_all = 0
function! ToggleHiddenAll()
    if s:hidden_all  == 0
        let s:hidden_all = 1
        set noshowmode
        set noruler
        set laststatus=0
        set noshowcmd
        set showtabline=0
        set nonumber
    else
        let s:hidden_all = 0
        set showmode
        set ruler
        set laststatus=2
        set showcmd
        set showtabline=1
        set number
    endif
endfunction

nnoremap <S-h> :call ToggleHiddenAll()<CR>
