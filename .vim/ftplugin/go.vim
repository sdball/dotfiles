set sw=2 ts=2 sts=2 noet
let t:all_command="go test ./... -v -json | jq-go-tests"
map <leader>r :wall\|:GoRun %<cr>
imap <c-f> <-
imap <c-t> <-

