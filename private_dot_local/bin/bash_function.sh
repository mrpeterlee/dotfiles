#!/usr/bin/env bash
# @Author     : Peter Lee
# @Email      : peter.lee@astrocapital.net
# @Last Update: 2024-05-21 09:48:53 EDT
# @Type       : lib
# @Sensitivity: global_equities@astrocapital.net
# @Platform   : any

# Helper functions for 1Password CLI usage.
# Kept minimal so they can be sourced in non-interactive shells.
_echo() {
  printf "\n╓───── %s \n╙────────────────────────────────────── ─ ─ \n" "$1"
}

get() {
  local acct="$1" item="$2" field="${3:-notesPlain}"
  op item get "$item" --account "$acct" --fields "$field" --format json | jq -rM '.value'
}

getfile() {
  local acct="$1" vault="$2" item="$3" field="${4:-notesPlain}"
  op --account "$acct" read "op://${vault}/${item}/${field}"
}

account() {
  local shorthand="$1" email="$2" domain="${3:-my}.1password.com"
  op account add \
    --address "$domain" \
    --email "$email" \
    --shorthand "$shorthand"
}
