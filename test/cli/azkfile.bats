#!/usr/bin/env bats

load ../test_helper

setup() {
  mkdir -p "$AZK_TEST_DIR"
  cd "$AZK_TEST_DIR"
}

create_file() {
  mkdir -p "$(dirname "$1")"
  touch "$1"
}

@test "in current directory" {
  create_file "$AZK_FILE_NAME"
  run azk-azkfile
  assert_success "${AZK_TEST_DIR}/${AZK_FILE_NAME}"
}

@test "in parent directory" {
  create_file "$AZK_FILE_NAME"
  mkdir -p project
  cd project
  run azk-azkfile
  assert_success "${AZK_TEST_DIR}/${AZK_FILE_NAME}"
}

@test "topmost file has precedence" {
  create_file "$AZK_FILE_NAME"
  create_file "project/${AZK_FILE_NAME}"
  cd project
  run azk-azkfile
  assert_success "${AZK_TEST_DIR}/project/${AZK_FILE_NAME}"
}

@test "AZK_DIR has precedence over PWD" {
  create_file "widget/${AZK_FILE_NAME}"
  create_file "project/${AZK_FILE_NAME}"
  cd project
  AZK_DIR="${AZK_TEST_DIR}/widget" run azk-azkfile
  assert_success "${AZK_TEST_DIR}/widget/${AZK_FILE_NAME}"
}

@test "PWD is searched if AZK_DIR yields no results" {
  mkdir -p "widget/blank"
  create_file "project/${AZK_FILE_NAME}"
  cd project
  AZK_DIR="${AZK_TEST_DIR}/widget/blank" run azk-azkfile
  assert_success "${AZK_TEST_DIR}/project/${AZK_FILE_NAME}"
}
