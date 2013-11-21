#!/usr/bin/env bats

load ../test_helper

setup() {
  mkdir -p "$AZK_TEST_DIR"
  cd "$AZK_TEST_DIR"
}

@test "required parameters" {
  run azk-provision
  assert_failure
  assert_match '^Usage:.*provision' "${lines[0]}"
}

@test "requires azkfile" {
  run azk-provision /bin/bash
  assert_failure "$(azk azkfile 2>&1)"
}

@test "requires exec in agent" {
  exec() {
    echo "$@"
    return 1;
  }
  export -f exec

  cp_fixture full_azkfile "${AZK_TEST_DIR}/project/azkfile.json"
  cd "project"

  run azk-provision box
  assert_failure
  assert_output "azk-agent-exec provision box"
}

@test "return ok if the box is already provisioned" {
  export box_name='azk/boxes:azukiapp_ruby-box_0.0.1'
  cp_fixture full_azkfile "${AZK_TEST_DIR}/project/azkfile.json"
  cd "project"

  azk-dcli() {
    if [[ "$@" == "--final /images/$box_name/json" ]]; then
      echo '{ "id": "4e220cf3e4156b0b1fd9" }'
      return 0;
    fi
    return 1;
  }; export -f azk-dcli

  run azk-provision --final box
  echo $output
  assert_success "azk: box $box_name already provisioned"
}
