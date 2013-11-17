#!/usr/bin/env bats

load ../test_helper

set_not_docker() {
  type() {
    [[ "$@" == "-t docker" ]] && exit 1
    command type $@
  }; export -f type;
}

@test "required parameters" {
  run azk-agent-exec
  assert_failure
  assert_match '^Usage:.*agent-exec' "${lines[0]}"
}

@test "docker exist? Execute a command" {
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

@test "not have docker and is final execute" {
  #mocks
  set_not_docker
  run azk-agent-exec --final exec
  assert_failure
  assert_match '^azk: cannot find docker or agent' "${lines[0]}"
}

@test "invalid agent host" {
  # mocks
  set_not_docker
  ssh() {
    [[ "$@" == "azk-agent.invalid echo 1" ]] && return 255;
    return 0;
  }; export -f ssh

  export AZK_AGENT_HOST="azk-agent.invalid"
  run azk-agent-exec exec
  assert_failure
  assert_match '^azk: cannot find docker or agent' "${lines[0]}"
}

mock_command() {
  command="$1"
  eval "
  $command() {
    [[ \"\$@\" == \"azk-agent echo 1\" ]] && return 0;
    shift
    exec \$@
  }; export -f $command
  "
}

@test "not docker and valid agent? Execute final command" {
  set_not_docker
  mock_command ssh

  run azk-agent-exec echo "hello"
  assert_success
}

