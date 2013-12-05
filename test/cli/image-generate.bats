#!/usr/bin/env bats

load ../test_helper

setup() {
  mkdir -p "$AZK_TEST_DIR"
  cd "$AZK_TEST_DIR"
}

@test "$test_label required parameters" {
  run azk-image-generate
  assert_failure
  assert_match '^Usage:.*image-generate' "${lines[0]}"

  run azk-image-generate box
  assert_failure
  assert_match '^Usage:.*image-generate' "${lines[0]}"

  run azk-image-generate box /
  assert_failure
  assert_match '^Usage:.*image-generate' "${lines[0]}"
}

@test "$test_label requires azkfile" {
  run azk-image-generate box $AZK_TEST_DIR image
  assert_failure "$(azk azkfile 2>&1)"
}

@test "$test_label provision image-box" {
  local clone_path="${AZK_TEST_DIR}/test-box"
  local fixture_path="$(fixtures test-box)"
  cp -rf $fixture_path $clone_path

  docker() {
    echo "$@"
  }; export -f docker

  run azk-image-generate box $clone_path image:tag
  assert_success "build -q -rm -t image:tag ."

  run cat $clone_path/Dockerfile
  assert_match 'FROM ubuntu:12.04' "${lines[0]}"
  assert_match "RUN echo '# step1'" "${lines[1]}"
  assert_match "RUN echo step1" "${lines[2]}"
}

mock_project() {
  local azkfile="${AZK_TEST_DIR}/project/azkfile.json"
  cp_fixture full_azkfile $azkfile
  local id=$(cat $azkfile | jq -r ".id")
  echo "azk/apps:$id"
}

@test "$test_label provision image-app" {
  local image_tag=$(mock_project)
  cd "project"
  local box_tag=$(azk-provision --get-name box)

  docker() {
    echo "$@"
  }; export -f docker

  run azk-image-generate app `pwd` $image_tag
  assert_success "build -q -rm -t $image_tag ."

  run cat Dockerfile
  assert_match "FROM $box_tag" "${lines[0]}"
  assert_match "RUN echo '# install binary deps'" "${lines[1]}"
  assert_match "RUN apt-get update" "${lines[2]}"
}
