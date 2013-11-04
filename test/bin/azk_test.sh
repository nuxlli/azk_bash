#!/bin/bash

 __FILE__="${0}"
_AZK_PATH=${_AZK_PATH:-`cd \`dirname $(readlink ${__FILE__} || echo ${__FILE__} )\`/../..; pwd`}

# Source azk
. ${_AZK_PATH}/bin/azk
export PATH=${_AZK_PATH}/bin:$PATH

testAzkVersion() {
  test="azk \${PARAM} | grep -q 'Azk [0-9]\+\.[0-9]\+\.[0-9]\+'"
  PARAM="-v"
  assertTrue "Azk get version by $PARAM" "$test"
  PARAM="--version"
  assertTrue "Azk get version by $PARAM" "$test"
}

testCheckAgent() {
  (
    # Stubs
    ping () {
      [[ "$@" == "-t 1 -c 1 azk-agent.test" ]] && return 0
      return 68
    }

    AZK_AGENT_HOST="azk-agent.test"
    assertTrue "Not resolve agent", "check_agent; [ \$? -eq 0 ]"

    AZK_AGENT_HOST="azk-agent.notexist"
    error_msg="Not found azk-agent in $AZK_AGENT_HOST"
    assertEquals "${error_msg}$(printf "\n68")" "$(check_agent 2>&1 || echo "$?")"
  )
}

testResolveAppDirInAgent() {
  (
    # Run in fixture path
    AZK_APPS_PATH=$(dir_resolve $(fixtures))

    cd ${AZK_APPS_PATH}
    assertEquals "${AZK_AGENT_APPS_PATH}" $(resolve_app_agent_dir)

    cd $(fixtures full_azkfile)
    assertEquals "${AZK_AGENT_APPS_PATH}/full_azkfile" "$(resolve_app_agent_dir)"
    assertTrue resolve_app_agent_dir

    cd ${AZK_APPS_PATH}/..
    error_msg="Not in azk application path"
    assertEquals "${error_msg}$(printf "\n1")" "$(resolve_app_agent_dir 2>&1 || echo "$?")"
  )
}

testExecuteInAgent() {
  (
    # Run in fixture path
    # Run in fixture path
    export AZK_APPS_PATH=$(dir_resolve $(fixtures))
    cd $(fixtures full_azkfile)
    app_path="$(resolve_app_agent_dir)"

    # Vars
    params=(
      "azk-agent cd $app_path; /vagrant/bin/azk.exs --help"
      "azk-agent cd $app_path; /vagrant/bin/azk.exs exec"
    ); export_a params

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

. ${_AZK_PATH}/test/test_helper.sh

