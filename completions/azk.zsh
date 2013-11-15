if [[ ! -o interactive ]]; then
    return
fi

compctl -K _azk azk

_azk() {
  local words completions
  read -cA words

  if [ "${#words}" -eq 2 ]; then
    completions="$(azk commands)"
  else
    completions="$(azk completions ${words[2,-2]})"
  fi

  reply=("${(ps:\n:)completions}")
}
