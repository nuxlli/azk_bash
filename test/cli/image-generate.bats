#!/usr/bin/env bats

load ../test_helper

azk_command="image-generate"

setup() {
  mkdir -p "$AZK_TEST_DIR"
  cd "$AZK_TEST_DIR"
}

@test "$test_label requires exec in agent" {
  path="${AZK_TEST_DIR}/project"
  mkdir -p $path
   tag="azk-fake"

  exec() {
    echo "$@"
    command exec $@;
  }; export -f exec

  run azk-$azk_command $path $tag
  assert_failure
  assert_match "azk-agent-exec image-generate azk-fake" "${lines[0]}"
  assert_match "`azk-azkfile --no-loop`" "${lines[1]}"
}

@test "$test_label requires azkfile" {
  run azk-image-generate $AZK_TEST_DIR image:tag
  assert_failure "$(azk azkfile --no-loop 2>&1)"
}

@test "$test_label provision image-box" {
  local clone_path="${AZK_TEST_DIR}/test-box"
  local fixture_path="$(fixtures test-box)"
  cp -rf $fixture_path $clone_path

  docker() {
    echo "$@"
  }; export -f docker

  run azk-image-generate $clone_path image:tag
  echo "$output"
  assert_success
  assert_equal "build -q -rm -t image:tag ." "${lines[3]}"

  run cat $clone_path/Dockerfile
  assert_match 'FROM ubuntu:12.04' "${lines[0]}"
  assert_match "RUN echo '# step1'" "${lines[1]}"
  assert_match "RUN echo step1" "${lines[2]}"
}

@test "$test_label provision image-app" {
  cp_fixture test-box ./test-box
  mkdir ./project
  cd ./project

  azkfile="${AZK_TEST_DIR}/project/azkfile.json"
  echo "{
    \"id\": \"$(azk-init --id)\",
    \"box\": \"../test-box\",
    \"build\": [
      \"# install binary deps\",
      \"apt-get update\"
    ]
  }" > $azkfile

   box_data=`azk-box info ../test-box`
  box_image="$(echo "$box_data" | jq -r ".image")"
  app_image="$(azk-app info | jq -r ".image")"

  azk-dcli() {
    [[ "$@" =~ ^.*test-box.*$ ]] && {
      echo '{ "id": "id_x" }'
      return 0
    }
    return 1
  }; export -f azk-dcli

  docker() {
    echo "$@"
  }; export -f docker

  run azk-image-generate --final
  echo "$output"
  assert_success
  assert_equal "build -q -rm -t $app_image ." "${lines[2]}"

  run cat Dockerfile
  assert_match "FROM $box_image" "${lines[0]}"
  assert_match "RUN echo '# install binary deps'" "${lines[1]}"
  assert_match "RUN apt-get update" "${lines[2]}"
  assert_match "RUN echo '$app_image' > /etc/azk_image" "${lines[3]}"
}
