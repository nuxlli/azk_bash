
# Fixture paths
fixtures () {
  echo "${_AZK_PATH}/test/fixtures/${1}"
}

exit_job () {
  code=${1};
  echo "${@}" > $pipe && exit $code
}

export -f exit_job

contains () {
    eval 'local values=("${'$1'[@]}")'

    local element
    for element in "${values[@]}"; do
        [[ "$element" == "$2" ]] && return 0
    done
    return 1
}

export -f contains

export_a () {
  export_name="__export_x_${1}"
  eval "export $export_name=\$(printf '%q ' \"\${$1[@]}\")"
}

import_a () {
  import_name="__export_x_${1}[*]"
  eval "${1}=( ${!import_name} )"
}

export -f import_a

# Tmp dir
tmp_path=$_AZK_PATH/tmp
if [[ ! -d $tmp_path ]]; then
  mkdir -p $tmp_path
fi

# Pipe to comunication subshell
pipe=$tmp_path/testpipe
trap "rm -f $pipe" EXIT
if [[ ! -p $pipe ]]; then
  mkfifo $pipe
fi

. $(dirname $0)/shunit2

rm -f $pipe
