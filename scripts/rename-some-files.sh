#!/usr/bin/bash

msg() {
  echo >&2 -e "${1-}"
}

fd '\[' | while read -r orig; do
  new=$(echo "$orig" | vis -m | sed -e 's/^.*=EF=BC=9A //' -e 's/ =.*$/.avi/')
  msg "renaming $orig"
  msg "     --> $new";
  mv "$orig" "$new"
done