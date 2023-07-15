#!/usr/bin/bash

msg() {
  echo >&2 -e "${1-}"
}

die() {
  msg "$1"
  exit 1
}

parse_params() {
  while :; do
    case "${1-}" in
    -d | --dry-run) DRY_RUN=1 ;;
    -?*) die "Unknown option: $1" ;;
    *) break ;;
    esac
    shift
  done

  return 0
}

parse_params "$@"

fd '\[' | while read -r orig; do
  new=$(echo "$orig" | vis -m | sed -e 's/^.*=EF=BC=9A //' -e 's/ =.*$/.avi/')
  msg "renaming $orig"
  msg "     --> $new";
  if [[ -z "$DRY_RUN" ]]; then
    mv "$orig" "$new"
  fi
done