#!/bin/bash

__FILE__="${0}"
export _AZK_PATH=`cd \`dirname $(readlink ${__FILE__} || echo ${__FILE__} )\`/../..; pwd`
export PATH=$_AZK_PATH/bin:$PATH

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

testAzkVersion() {
  test="azk \${PARAM} | grep -q 'Azk [0-9]\+\.[0-9]\+\.[0-9]\+'"
  PARAM="-v"
  assertTrue "Azk get version by $PARAM" "$test"
  PARAM="--version"
  assertTrue "Azk get version by $PARAM" "$test"
}

testCheckAgent() {
  (
    ping () {
      [ "$(echo $@)" == "-t 1 -c 1 azk-agent" ] && exit 0
      [ "$(echo $@)" == "-t 1 -c 1 azk-agent.test" ] && exit 0
      exit 68
    }
    export -f ping
    (
      azk --help
      assertTrue "azk --help"
      export AZK_AGENT_HOST="azk-agent.test"
      azk --help
      assertTrue "azk --help"
      export AZK_AGENT_HOST="azk-agent.notexist"
      azk --help
      assertTrue "azk --help; [ \$? -eq 68 ]"
    )
  )
}

. $(dirname $0)/shunit2

rm -f $pipe
