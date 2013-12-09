#!/usr/bin/env bats

load ../test_helper
source `azk-root`/private/bin/common.sh

setup() {
  mkdir -p "$AZK_TEST_DIR"
  cd "$AZK_TEST_DIR"
}

@test "$test_label required parameters" {
  run azk-box
  assert_failure
  assert_match '^Usage:.*box' "${lines[0]}"
}

@test "$test_label support github format" {
  run azk-box info "azukiapp/ruby-box#stable"
  assert_success

  type="github"
  repo="https://github.com/azukiapp/ruby-box"
  path="azukiapp/ruby-box"
  version="stable"
  image="azukiapp/ruby-box:stable"

  assert_equal "$type"    $(echo $output | jq -r ".type")
  assert_equal "$repo"    $(echo $output | jq -r ".repository")
  assert_equal "$path"    $(echo $output | jq -r ".clone_path")
  assert_equal "$version" $(echo $output | jq -r ".version")
  assert_equal "$image"   $(echo $output | jq -r ".image")

  run azk-box info "azukiapp/ruby-box"
  assert_success
  assert_equal "master" $(echo $output | jq -r ".version")
}

@test "$test_label support path format" {
  type="path"
  path="${AZK_TEST_DIR}"
  version="$(tar c $path | azk.hash)"
  image="$path:$version"

  run azk-box info $path
  assert_success

  assert_equal "$type"    $(echo $output | jq -r ".type")
  assert_equal "null"     $(echo $output | jq -r ".repository")
  assert_equal "$path"    $(echo $output | jq -r ".clone_path")
  assert_equal "$version" $(echo $output | jq -r ".version")
  assert_equal "$image"   $(echo $output | jq -r ".image")
}

@test "$test_label expand relative path" {
  path="./box/"
  mkdir -p "$path"

  run azk-box info $path
  assert_success

  assert_equal "path"       $(echo $output | jq -r ".type")
  assert_equal "$(pwd)/box" $(echo $output | jq -r ".clone_path")

  mkdir -p "./app"
  run eval "cd './app'; azk-box info '../box'"

  assert_equal "path"       $(echo $output | jq -r ".type")
  assert_equal "$(pwd)/box" $(echo $output | jq -r ".clone_path")
}

@test "$test_label show a erro if path not found" {
  run azk-box info ./novalid
  assert_failure "azk: box path './novalid' not found"
}

@test "$test_label support docker image format" {
  run azk-box info docker:ubuntu:12.04
  echo "$output"
  assert_success

  assert_equal "docker" $(echo $output | jq -r ".type")
  assert_equal "null"  $(echo $output | jq -r ".clone_path")
  assert_equal "null"  $(echo $output | jq -r ".repository")
  assert_equal "12.04" $(echo $output | jq -r ".version")
  assert_equal "ubuntu:12.04" $(echo $output | jq -r ".image")

  run azk-box info docker:azk/ima-g_e
  assert_success

  assert_equal "azk/ima-g_e" $(echo $output | jq -r ".image")
  assert_equal "latest" $(echo $output | jq -r ".version")
}

@test "$test_label unsupported box definition" {
  box="%%#^%@"
  run azk-box info "$box"
  assert_failure "azk: '$box' is not a valid definition of box"
}
