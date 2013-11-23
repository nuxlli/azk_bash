#!/usr/bin/env bats

#test_label="cli/provision:"

load ../test_helper

setup() {
  mkdir -p "$AZK_TEST_DIR"
  cd "$AZK_TEST_DIR"
  export TERM=""

  mkdir -p "$HOME"
  git config --global user.name  "Tester"
  git config --global user.email "tester@test.local"
}

git_commit() {
  command git commit --quiet --allow-empty -m "empty"
}; export -f git_commit

mock_git_clone() {
  export AZK_DATA_PATH="${AZK_TEST_DIR}/data"
  export test_clone_url="https://github.com/azukiapp/test-box"
  export test_clone_path="${AZK_DATA_PATH}/boxes/azukiapp/test-box"
  export test_fixture_path="$(fixtures test-box)"

  git() {
    clone_path="${AZK_DATA_PATH}/boxes/azukiapp/test-box"
    mkdir -p "$(dirname "$clone_path")"
    if [[ "$@" == "clone $test_clone_url $clone_path" ]]; then
      cp -rf $test_fixture_path $clone_path
      cd $clone_path
      git init 1>/dev/null;
      echo "Cloning into '$clone_path'..."
      git add .
      git commit --quiet -m "First version"
      git tag v0.0.1
      return 0;
    fi
    if [[ "$@" == "--git-dir=${clone_path}/.git remote update" ]]; then
      cd $clone_path
      echo "v0.0.2" > version
      git add .
      git commit --quiet -m "Second version"
      git tag v0.0.2
      echo "Fetching origin"
      return 0;
    fi
    command git "$@";
  }; export -f git
}

@test "$test_label required parameters" {
  run azk-provision
  assert_failure
  assert_match '^Usage:.*provision' "${lines[0]}"
}

@test "$test_label requires azkfile" {
  run azk-provision /bin/bash
  assert_failure "$(azk azkfile 2>&1)"
}

@test "$test_label requires exec in agent" {
  exec() {
    echo "$@"
    return 1;
  }
  export -f exec

  cp_fixture full_azkfile "${AZK_TEST_DIR}/project/azkfile.json"
  cd "project"

  run azk-provision box
  assert_failure
  assert_output "azk-agent-exec provision box"
}

# TODO: Reducing coupling test
@test "$test_label return ok if the image for this box is already provisioned" {
  export box_name='azk/boxes:azukiapp_test-box_v0.0.1'
  cp_fixture full_azkfile "${AZK_TEST_DIR}/project/azkfile.json"
  cd "project"

  azk-dcli() {
    if [[ "$@" == "--final /images/$box_name/json" ]]; then
      echo '{ "id": "4e220cf3e4156b0b1fd9" }'
      return 0;
    fi
    return 1;
  }; export -f azk-dcli

  run azk-provision --final box
  assert_success
  assert_match "azk: searching '$box_name'" "${lines[0]}"
  assert_match "azk: '$box_name' already provisioned" "${lines[1]}"
}

@test "$test_label call git to clone repository of box" {
  export box_name='azk/boxes:azukiapp_test-box_v0.0.1'
  cp_fixture full_azkfile "${AZK_TEST_DIR}/project/azkfile.json"
  cd "project"

  export test_clone_url="https://github.com/azukiapp/test-box"

  azk-dcli() {
    echo '{}'; return 0;
  }; export -f azk-dcli

  git() {
    clone_path="`azk root`/data/boxes/azukiapp/test-box"
    [[ "$@" == "clone $test_clone_url $clone_path" ]] && echo "git-clone" && return 1;
    [[ "$@" == "--git-dir=$clone_path/.git rev-parse" ]] && echo "git-rev-parse" && return 1;
    return 0;
  }; export -f git

  run azk-provision --final box
  assert_failure
  assert_equal "azk: '$box_name' not found" "${lines[1]}"
  assert_equal "azk: get box '${test_clone_url}#v0.0.1'..." "${lines[2]}"
  assert_equal "azk: could not get or update the box $test_clone_url repository" "${lines[3]}"
}

@test "$test_label checkout to version" {
  cp_fixture full_azkfile "${AZK_TEST_DIR}/project/azkfile.json"
  cd "project"

  azk-dcli() {
    echo '{}'; return 0;
  }; export -f azk-dcli

  azk-image-generate() {
    return 0;
  }; export -f azk-image-generate

  mock_git_clone

  run azk-provision --final box 2>&1
  assert_success
  assert_match "azk: get box '$test_clone_url#v0.0.1'..." "${lines[2]}"
  assert_match "azk: check for version 'v0.0.1'..." "${lines[3]}"

  run git --git-dir="${test_clone_path}/.git" branch
  assert_success

  values=( '* (detached from v0.0.1)' '* (no branch)' )
  assert_include values "${lines[0]}"
}

@test "$test_label if exist clone, only checkout version" {
  azk_file="${AZK_TEST_DIR}/project/azkfile.json"
  cp_fixture full_azkfile $azk_file
  cd "project"

  azk-dcli() {
    echo '{}'; return 0;
  }; export -f azk-dcli

  azk-image-generate() {
    return 0;
  }; export -f azk-image-generate

  mock_git_clone

  run azk-provision --final box
  assert_success

  cat $(fixtures full_azkfile.json) | sed 's:test-box#v0.0.1:test-box#v0.0.2:g' > $azk_file
  run azk-provision --final box
  assert_success
  assert_match "azk: check for box updates in '${test_clone_url}#v0.0.2'..." "${lines[2]}"
  assert_match "azk: check for version 'v0.0.2'..." "${lines[3]}"
}

@test "$test_label at the end generate image" {
  azk_file="${AZK_TEST_DIR}/project/azkfile.json"
  cp_fixture full_azkfile $azk_file
  cd "project"

  azk-dcli() {
    echo '{}'; return 0;
  }; export -f azk-dcli

  azk-image-generate() {
    echo "$@"
  }; export -f azk-image-generate

  mock_git_clone

  run azk-provision --final box
  assert_success
  assert_match "box $test_clone_path azk/boxes:azukiapp_test-box_v0.0.1" "${lines[4]}"
}
