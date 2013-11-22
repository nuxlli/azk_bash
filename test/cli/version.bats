#!/usr/bin/env bats

load ../test_helper

setup() {
  mkdir -p "$HOME"
  git config --global user.name  "Tester"
  git config --global user.email "tester@test.local"
}

git_commit() {
  git commit --quiet --allow-empty -m "empty"
}

@test "$test_label default version" {
  export AZK_ROOT="${AZK_TEST_DIR}/root"
  assert [ ! -e "$AZK_ROOT" ]
  run azk-version
  assert_success
  [[ $output == "azk 0."* ]]
}

@test "$test_label reads version from git repo" {
  export AZK_ROOT="${AZK_TEST_DIR}/root"
  mkdir -p "$AZK_ROOT"
  cd "$AZK_ROOT"
  git init
  git_commit
  git tag v0.4.1
  git_commit
  git_commit

  cd "$AZK_TEST_DIR"
  run azk-version
  assert_success
  [[ $output == "azk 0.4.1-2-g"* ]]
}

@test "$test_label prints default version if no tags in git repo" {
  export AZK_ROOT="${AZK_TEST_DIR}/root"
  mkdir -p "$AZK_ROOT"
  cd "$AZK_ROOT"
  git init
  git_commit

  cd "$AZK_TEST_DIR"
  run azk-version
  [[ $output == "azk 0."* ]]
}
