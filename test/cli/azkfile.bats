#!/usr/bin/env bats

load ../test_helper

setup() {
  mkdir -p "$AZK_TEST_DIR"
  cd "$AZK_TEST_DIR"
}

@test "$test_label does not exist $AZK_FILE_NAME" {
  run azk azkfile
  assert_failure
  assert_output "azk: no such '${AZK_FILE_NAME}' in current project"
}

@test "$test_label in current directory" {
  create_file "$AZK_FILE_NAME"
  run azk-azkfile
  assert_success "${AZK_TEST_DIR}/${AZK_FILE_NAME}"
}

@test "$test_label in parent directory" {
  create_file "$AZK_FILE_NAME"
  mkdir -p project
  cd project
  run azk-azkfile
  assert_success "${AZK_TEST_DIR}/${AZK_FILE_NAME}"
}

@test "$test_label topmost file has precedence" {
  create_file "$AZK_FILE_NAME"
  create_file "project/${AZK_FILE_NAME}"
  cd project
  run azk-azkfile
  assert_success "${AZK_TEST_DIR}/project/${AZK_FILE_NAME}"
}

@test "$test_label AZK_DIR has precedence over PWD" {
  create_file "widget/${AZK_FILE_NAME}"
  create_file "project/${AZK_FILE_NAME}"
  cd project
  AZK_DIR="${AZK_TEST_DIR}/widget" run azk-azkfile
  assert_success "${AZK_TEST_DIR}/widget/${AZK_FILE_NAME}"
}

@test "$test_label PWD is searched if AZK_DIR yields no results" {
  mkdir -p "widget/blank"
  create_file "project/${AZK_FILE_NAME}"
  cd project
  AZK_DIR="${AZK_TEST_DIR}/widget/blank" run azk-azkfile
  assert_success "${AZK_TEST_DIR}/project/${AZK_FILE_NAME}"
}

@test "$test_label valid azkfile.json" {
  echo "{" > "${AZK_FILE_NAME}"
  run azk-azkfile
  assert_failure
  assert_equal "parse error: Unfinished JSON term" "${lines[0]}"
  assert_equal "azk: '${AZK_TEST_DIR}/${AZK_FILE_NAME}' is not valid json format" "${lines[1]}"

  echo "{}" > azkfile.json
  run azk-azkfile
  assert_success "${AZK_TEST_DIR}/${AZK_FILE_NAME}"
}

@test "$test_label clear comments in valid json file" {
  echo "{ /* comment */ }" > "${AZK_FILE_NAME}"
  run azk-azkfile
  assert_success
}
