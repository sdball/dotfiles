set ai sw=4 sts=4 et
map <leader>s :RustFmt<cr>
imap <c-d> #[derive()]<ESC>hi
imap <c-a> #![allow()]<ESC>hi
imap <c-f> fn ()<ESC>hha
imap <c-p> println!("");<ESC>hhi
imap <c-e> {}
imap <c-r> {:?}
imap <s-tab> fn main() {<CR>}<ESC>O
if filereadable("Cargo.toml")
  map <leader>r :wall\|:!cargo run<cr>
  map <leader>b :wall\|:!cargo build<cr>
  map <leader>t :wall\|:!cargo test -- --color always --nocapture<cr>
else
  map <leader>r :wall\|:!rustc % && ./%:r<cr>
endif
let b:ale_fixers = ['rustfmt']
let g:ale_rust_cargo_use_clippy = 1
