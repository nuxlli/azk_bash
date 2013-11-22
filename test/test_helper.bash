unset AZK_VERSION
unset AZK_DIR

 __FILE__="${BASH_SOURCE}"
_AZK_PATH=${_AZK_PATH:-`cd \`dirname $(readlink ${__FILE__} || echo ${__FILE__} )\`/..; pwd`}

AZK_FILE_NAME="azkfile.json"
 AZK_TEST_DIR="${BATS_TMPDIR}/azk"
HOME="${AZK_TEST_DIR}/home"

PATH=/usr/bin:/bin:/usr/sbin:/sbin
PATH="${AZK_TEST_DIR}/bin:$PATH"
PATH="${_AZK_PATH}/private/bin:$PATH"
PATH="${_AZK_PATH}/test/fixtures/libexec:$PATH"
PATH="${_AZK_PATH}/libexec:$PATH"
export PATH

# Label to use in test
test_folder=`cd \`dirname $(readlink ${__FILE__} || echo ${__FILE__} )\`; pwd`
test_folder=$(echo $test_folder | sed 's/\//\\\//g')
test_folder=$(echo "$(dirname "${BATS_TEST_FILENAME}")" | sed 's/'"${test_folder}"'//g')
export test_label="${test_folder}/$(basename -s .bats "${BATS_TEST_FILENAME}"):"

teardown() {
  rm -rf "$AZK_TEST_DIR"
}

flunk() {
  { if [ "$#" -eq 0 ]; then cat -
    else echo "$@"
    fi
  } | sed "s:${AZK_TEST_DIR}:TEST_DIR:g" >&2
  return 1
}

assert_success() {
  if [ "$status" -ne 0 ]; then
    flunk "command failed with exit status $status"
  elif [ "$#" -gt 0 ]; then
    assert_output "$1"
  fi
}

assert_failure() {
  if [ "$status" -eq 0 ]; then
    flunk "expected failed exit status"
  elif [ "$#" -gt 0 ]; then
    assert_output "$1"
  fi
}

assert_equal() {
  if [ "$1" != "$2" ]; then
    { echo "expected: $1"
      echo "actual:   $2"
    } | flunk
  fi
}

assert_match() {
  if [ ! $(echo "${2}" | grep -- "${1}") ]; then
    { echo "expected match: $1"
      echo "actual: $2"
    } | flunk
  fi
}

assert_output() {
  local expected
  if [ $# -eq 0 ]; then expected="$(cat -)"
  else expected="$1"
  fi
  assert_equal "$expected" "$output"
}

assert_line() {
  if [ "$1" -ge 0 ] 2>/dev/null; then
    assert_equal "$2" "${lines[$1]}"
  else
    local line
    for line in "${lines[@]}"; do
      if [ "$line" = "$1" ]; then return 0; fi
    done
    flunk "expected line \`$1'"
  fi
}

refute_line() {
  if [ "$1" -ge 0 ] 2>/dev/null; then
    local num_lines="${#lines[@]}"
    if [ "$1" -lt "$num_lines" ]; then
      flunk "output has $num_lines lines"
    fi
  else
    local line
    for line in "${lines[@]}"; do
      if [ "$line" = "$1" ]; then
        flunk "expected to not find line \`$line'"
      fi
    done
  fi
}

assert_include() {
  eval 'local values=("${'$1'[@]}")'

  local element
  for element in "${values[@]}"; do
      [[ "$element" == "$2" ]] && return 0
  done

  flunk "failed: array ${values[*]} not include $2}"
}

assert() {
  if ! "$@"; then
    flunk "failed: $@"
  fi
}

fixtures() {
  echo "${_AZK_PATH}/test/fixtures/${1}"
}

cp_fixture() {
  mkdir -p "$(dirname "$2")"
  cp "$(fixtures $1).json" $2
}

create_file() {
  mkdir -p "$(dirname "$1")"
  touch "$1"
}

p() {
  echo "$@" >&2
  exit 1000
}
