#!/usr/bin/env bats

load ../test_helper

@test "blank invocation" {
  #mocks
  ssh() { echo $@; }
  export -f ssh;

  run azk-agent-ssh
  assert_failure
}

@test "ssh connect" {
  #mocks
  ssh() { echo $@; }
  export -f ssh;

  run azk-agent-ssh azk-agent
  assert_success
  assert_match '^core@azk-agent ' "$output"
  assert_match "${_AZK_ROOT}/libexec/../private/etc/insecure_private_key\$" "$output"
  assert_match '-o DSAAuthentication=yes' "$output"
  assert_match '-o StrictHostKeyChecking=no' "$output"
  assert_match '-o UserKnownHostsFile=/dev/null' "$output"
  assert_match '-o LogLevel=FATAL' "$output"
  assert_match '-o IdentitiesOnly=yes' "$output"
}

@test "execute a command" {
  ssh() { echo $@; }
  export -f ssh;
  run azk-agent-ssh azk-agent echo 1
  assert_success
  assert_match 'echo 1$' "$output"
}
