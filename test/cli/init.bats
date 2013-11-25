#!/usr/bin/env bats

load ../test_helper

setup() {
  mkdir -p "$AZK_TEST_DIR"
  cd "$AZK_TEST_DIR"
}

@test "$test_label create a new app id" {
  uuidgen() {
    echo "883AF6EC-F05F-4037-9A6D-FA9FD6FAF995";
  }; export -f uuidgen;

  run azk-init --id
  assert_success "883af6ecf05f40379a6dfa9fd6faf995"
}

@test "$test_label with box" {
  box="azukiapp/test-box#0.0.1"

  assert [ ! -f "$AZK_FILE_NAME" ]
  run azk-init --box $box
  assert_success
  assert_equal "azk: [init] './${AZK_FILE_NAME}' generated" "$output"

  run cat azkfile.json
  assert_success
  echo "$output"
  assert_match "\"id\": \"[a-zA-Z0-9]\{32\}\"," "${lines[2]}"
  assert_match "\"box\": \"$box\"," "${lines[3]}"
}

@test "$test_label respects the given path" {
  run azk-init ./foo/project --box xyz
  assert_success
  assert_equal "azk: [init] './foo/project/${AZK_FILE_NAME}' generated" "$output"
  assert [ -d "./foo/project" ]
}

@test "$test_label fails if the file already exists azkfile" {
  file="./project/${AZK_FILE_NAME}"
  create_file $file

  run azk-init ./project --box xyz
  assert_failure "azk: [init] '$file' already exists"
}

@test "$test_label confirm default box" {
  echo "" | azk-init
  box=$(cat azkfile.json | jq -r ".box")
  assert_equal "azukiapp/[box]#[version]" "$box"
}

@test "$test_label enter a box" {
  echo "azukiapp/ruby-box#0.0.1" | azk-init
  box=$(cat azkfile.json | jq -r ".box")
  assert_equal "azukiapp/ruby-box#0.0.1" "$box"
}

@test "$test_label sugest ruby box" {
  touch Gemfile
  echo "" | azk-init

  box=$(cat azkfile.json | jq -r ".box")
  assert_equal "azukiapp/ruby-box#stable" "$box"
}

@test "$test_label sugest node box" {
  touch package.json
  echo "" | azk-init

  box=$(cat azkfile.json | jq -r ".box")
  assert_equal "azukiapp/node-box#stable" "$box"
}

@test "$test_label sugest elixir box" {
  touch mix.exs
  echo "" | azk-init

  box=$(cat azkfile.json | jq -r ".box")
  assert_equal "azukiapp/elixir-box#stable" "$box"
}
