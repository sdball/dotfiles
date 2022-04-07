set sw=2 ts=2 sts=2 noet
map <leader>r :wall\|:GoRun %<cr>
imap <c-f> <-
imap <c-t> <-
function! RunAllTests()
  let g:run_all_tests = 1
  call RunTestFile()
  unlet g:run_all_tests
endfunction
