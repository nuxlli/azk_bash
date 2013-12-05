#!/usr/bin/env bats

load ../test_helper

setup() {
  mkdir -p "$AZK_TEST_DIR"
  cd "$AZK_TEST_DIR"
}

set_not_docker() {
  type() {
    [[ "$@" == "-t docker" ]] && exit 1
    command type $@
  }; export -f type;
}

@test "$test_label required parameters" {
  run azk-agent-exec
  assert_failure
  assert_match '^Usage:.*agent-exec' "${lines[0]}"
}

@test "$test_label docker exist? Execute a command" {
  # mocks
  docker () { echo "Docker"; }
  azk () { echo $@; }
  export -f docker;
  export -f azk;

  command="/bin/bash -c 'cd ~/; echo \"hello\"'"
  run azk-agent-exec exec $command
  assert_success
  assert_output "exec --final $command"
}

@test "$test_label not have docker and is final execute" {
  # mocks
  set_not_docker
  run azk-agent-exec --final exec
  assert_failure
  assert_match '^azk: cannot find docker or agent' "${lines[0]}"
}

@test "$test_label invalid agent host" {
  # mocks
  set_not_docker
  azk-agent-ssh() {
    [[ "$@" == "192.168.115.4 echo 1" ]] && return 255;
    return 0;
  }; export -f azk-agent-ssh

  export AZK_AGENT_IP="192.168.115.4"
  run azk-agent-exec exec
  assert_failure
  assert_match '^azk: cannot find docker or agent' "${lines[0]}"
}

@test "$test_label not docker and valid agent? Execute final command" {
  set_not_docker
  azk-agent-ssh() {
    [[ "$@" == "azk-agent echo 1" ]] && return 0;
    echo "$@"
    return 0;
  }; export -f azk-agent-ssh

  export AZK_APPS_PATH="${AZK_TEST_DIR}"
  mkdir -p $AZK_TEST_DIR/project
  cd project

  export TERM=term
  export AZK_INTERACTIVE=true
  export AZK_AGENT_IP="192.168.115.4"

  local envs="export TERM=${TERM}; export AZK_DEBUG=$AZK_DEBUG; export AZK_INTERACTIVE=$AZK_INTERACTIVE; export AZK_ENV=$AZK_ENV"
  local path="/home/core/azk"

  azk-agent-exec echo "any value"
  run azk-agent-exec echo "any value"
  assert_success
  assert_output "${AZK_AGENT_IP}  $envs; cd $path/data/apps/project; $path/libexec/azk echo --final any\\ value"
}

@test "$test_label show erro if not valid azk-agent path" {
  set_not_docker
  azk-agent-ssh() {
    [[ "$@" == "192.168.115.4 echo 1" ]] && return 0;
  }; export -f azk-agent-ssh

  export AZK_AGENT_IP="192.168.115.4"
  export AZK_APPS_PATH="${AZK_TEST_DIR}/projects"

  run azk-agent-exec echo "any value"
  assert_failure
  assert_output "azk: not in azk applications path"
}
