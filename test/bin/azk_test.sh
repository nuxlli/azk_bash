#!/bin/bash

__FILE__="${0}"
export _AZK_PATH=`cd \`dirname $(readlink ${__FILE__} || echo ${__FILE__} )\`/../..; pwd`
export PATH=$_AZK_PATH/bin:$PATH

testAzkVersion() {
  test="azk \${PARAM} | grep -q 'Azk [0-9]\+\.[0-9]\+\.[0-9]\+'"
  PARAM="-v"
  assertTrue "Azk get version by $PARAM" "$test"
  PARAM="--version"
  assertTrue "Azk get version by $PARAM" "$test"
}

testCheckAgent() {
  (
    ssh () { return 0; }
    ping () {
      [ "$(echo $@)" == "-t 1 -c 1 azk-agent" ] && exit 0
      [ "$(echo $@)" == "-t 1 -c 1 azk-agent.test" ] && exit 0
      exit 68
    }
    export -f ping; export -f ssh
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

testExecuteInAgent() {
  (
    # Vars
    params=(
      'azk-agent cd /vagrant; ./bin/azk --help'
      'azk-agent cd /vagrant; ./bin/azk exec'
    )

    export_a params

    # Run in fixture path
    cd $(fixtures full_azkfile)

    # Mocks
    ping () { exit 0; }
    ssh () {
      import_a params
      eval "contains params '${@}'" && exit_job 0 "${@}"
      exit_job 1 "${@}"
    }
    export -f ping; export -f ssh; export pipe

    (
      $(sleep 0.5; azk --help; echo $? >$pipe ) &
      assertEquals "0 ${params[0]}" "$(<$pipe)" # ssh return
      assertTrue "[ $(<$pipe) == "0" ]" # azk return

      $(sleep 0.5; azk exec; echo $? >$pipe ) &
      assertEquals "0 ${params[1]}" "$(<$pipe)" # ssh return
      assertTrue "[ $(<$pipe) == "0" ]" # azk return
    )
  )
}

. $(dirname $0)/../test_helper.sh

