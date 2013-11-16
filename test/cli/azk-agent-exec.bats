#!/usr/bin/env bats

load ../test_helper

@test "required parameters" {
  run azk-agent-exec
  assert_failure
  assert_match '^Usage:.*agent-exec' "${lines[0]}"
}

@test "docker exist? Execute a command" {
  # mocks
  uname ()  { echo "Linux"; }
  docker () { echo "Docker"; }
  azk () { echo $@; }
  export -f docker;
  export -f uname;
  export -f azk;

  command="/bin/bash -c 'cd ~/; echo \"hello\"'"
  run azk-agent-exec exec $command
  assert_success
  assert_output "exec --final $command"
}

@test "operacional system not supported" {
  # mocks
  uname () { exit 1; }; export -f uname

  run azk agent-exec exec
  assert_failure
  assert_match '^azk: SO not.*azk-agent?' "${lines[0]}"
}
