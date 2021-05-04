TODO profile command

```
/usr/local/bin/zsh -c "cd ~/Documents/worklog ; fd . | rg -v \"$(date +%Y-%m-%d.md)\" | xargs chmod -w ; /usr/local/bin/vim +':call NextColor(0)' \"$(date +'%Y-%m-%d').md\""
```

