#!/usr/bin/env bats

load ../test_helper

azk_command="azk-image-provision"

setup() {
  mkdir -p "$AZK_TEST_DIR"
  cd "$AZK_TEST_DIR"
}

@test "$test_label requires exec in agent" {
  export azkfile="$AZK_TEST_DIR/$AZK_FILE_NAME"

  exec() {
    [[ "$@" == "azk-agent-exec image-provision $azkfile" ]] && echo "$@" && return 1;
    command exec $@;
  }
  export -f exec

  run $azk_command $azkfile
  assert_failure
  assert_output "azk-agent-exec image-provision $azkfile"
}

@test "$test_label use a current $AZK_FILE_NAME" {
  run $azk_command
  assert_failure `azk-azkfile`

  file="$AZK_TEST_DIR/$AZK_FILE_NAME"
  echo "}" > $file

  run $azk_command --final
  assert_failure
  assert_equal "azk: '$file' is not valid json format" "${lines[1]}"
}

@test "$test_label requires box value" {
  file="$AZK_TEST_DIR/$AZK_FILE_NAME"
  echo "{}" > $file

  run $azk_command --final
  echo "$output"
  assert_failure "azk: '$file' not have a box entry (required)."
}

@test "$test_label requires valid box value" {
  file="$AZK_TEST_DIR/$AZK_FILE_NAME"
  echo '{ "box": "invalid#box" }' > $file

  run $azk_command --final
  echo "$output"
  assert_failure `azk-box info invalid#box`
}

@test "$test_label pull docker image" {
  file="$AZK_TEST_DIR/$AZK_FILE_NAME"
  export docker_box="azukiapp/blank"
  echo "{ \"box\": \"docker:$docker_box\" }" > $file

  run $azk_command
  echo "$output"
  assert_failure
  assert_match 'Type box detected: docker' "${lines[0]}"
  assert_match "searching docker image: '$docker_box'" "${lines[1]}"
  assert_match "Pulling repository $docker_box" "${lines[2]}"
}

@test "$test_label return image name if success" {
  file="$AZK_TEST_DIR/$AZK_FILE_NAME"
  echo "{ \"box\": \"docker:ubuntu:12.04\" }" > $file

  run eval "$azk_command 2>/dev/null"
  assert_success "ubuntu:12.04"
}
