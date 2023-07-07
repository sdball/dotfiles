#!/usr/bin/env bash

# https://gist.github.com/lmammino/920ee0699af627a3492f86c607c859f6

# Example usage:
#   jwtinfo.sh "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c"

function decode {
  read token
  _l=$((${#token} % 4))
  if [ $_l -eq 2 ]; then _s="$token"'=='
  elif [ $_l -eq 3 ]; then _s="$token"'='
  else _s="$token" ; fi
  echo "$_s" | tr '_-' '/+' | openssl enc -d -a -A
}

jwtinfo ()
{
  echo "$1" | cut -d'.' -f 2 | decode 2> /dev/null | jq .
}

jwtinfo "$1"

# Inspired by code from @Moodstocks, @deltheil and @xatier
# References:
#  - https://github.com/Moodstocks/moodstocks-api-clients/blob/master/bash/base64url.sh
#  - https://github.com/lmammino/jwtinfo/issues/5
