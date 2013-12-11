#!/usr/bin/env bats

load ../test_helper

azk_command="image-provision"

setup() {
  mkdir -p "$AZK_TEST_DIR"
  cd "$AZK_TEST_DIR"
}

@test "$test_label requires exec in agent" {
  export exec_cmd="azk-agent-exec $azk_command ubuntu:12.04"
  exec() {
    echo "$@"; return 1;
  }; export -f exec

  run azk-$azk_command ubuntu:12.04
  assert_failure "$exec_cmd"
}

@test "$test_label required parameters" {
  run azk-$azk_command --final
  assert_failure
  assert_match "^Usage:.*$azk_command" "${lines[0]}"
}

@test "$test_label requires valid box value" {
  run azk-$azk_command --final "invalid#box"
  assert_failure `azk-box info invalid#box`
}

@test "$test_label pull docker image in docker type" {
  docker_box="azukiapp/blank:latest"

  run azk-$azk_command $docker_box
  echo "$output"
  assert_failure
  assert_match 'Type box detected: docker' "${lines[0]}"
  assert_match "Searching docker image: '$docker_box'" "${lines[1]}"
  assert_match "'$docker_box' not found, provision it..." "${lines[2]}"
  assert_match "Pulling repository" "${lines[3]}"
}

@test "$test_label generate image for path" {
  mkdir fake-box
  echo '{ "box": "ubuntu:12.04" }' > "./fake-box/$AZK_FILE_NAME"

  mkdir ./project; cd ./project

  run azk-"$azk_command" "../fake-box"
  echo "$output"
  assert_match 'Type box detected: path' "${lines[0]}"
  assert_match "Searching docker image: .*/fake-box:[[:alnum:]]*'" "${lines[1]}"
  assert_match "'.*/fake-box:[[:alnum:]]*' not found, provision it" "${lines[2]}"
  assert_match "Type box detected: docker" "${lines[4]}"
  assert_match "'.*/fake-box:[[:alnum:]]*' provisioned" "$output"
  assert_success
}

@test "$test_label return image name if success" {
  run eval "azk-$azk_command ubuntu:12.04 2>/dev/null"
  assert_success "ubuntu:12.04"
}
