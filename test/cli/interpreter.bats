#!/usr/bin/env bats

load ../test_helper

setup() {
  mkdir -p "$AZK_TEST_DIR"
  cd "$AZK_TEST_DIR"
}

mock_cmd() {
  export command="interpreter-test"
  export script="${AZK_TEST_DIR}/bin/azk-$command"
  create_file "$script"
  chmod +x $script

  echo '#!/usr/bin/env azk-interpreter' > $script
}

@test "$test_label required parameters" {
  run azk-interpreter
  assert_failure
  assert_match '^Usage:.*interpreter' "${lines[0]}"
}

@test "$test_label run azk command" {
  mock_cmd
  echo 'echo "$@"' > $script

  msg="run in $command"
  run azk-interpreter $script $msg
  assert_success "$msg"
}

@test "$test_label be used as a interpreter" {
  mock_cmd
  echo 'echo "$@"' >> $script

  msg="run in $command"
  run $script $msg
  assert_success "$msg"
}

@test "$test_label set a azk command informations" {
  mock_cmd
  echo 'echo "$azk_command"' >> $script

  run $script
  assert_success "$command"
}

@test "$test_label implement helper azk.run_internal" {
  mock_cmd
  echo "${command}_internal() { echo \"\$@\"; }" >> $script
  echo 'azk.run_internal "$@"' >> $script

  run $script internal arg1 arg2
  assert_success "arg1 arg2"
}

@test "$test_label show unsupported command message" {
  mock_cmd
  echo "# Usage: $command" >> $script
  echo 'azk.run_internal "$@"' >> $script

  run $script internal arg1 arg2
  assert_failure
  assert_equal "azk: 'internal' unsupported command" "${lines[0]}"
  assert_equal "Usage: $command" "${lines[1]}"
}
