#!/usr/bin/env bats

load ../test_helper
source `azk-root`/private/bin/common.sh

setup() {
  mkdir -p "$AZK_TEST_DIR"
  cd "$AZK_TEST_DIR"
}

@test "$test_label return app informations" {
  path="${AZK_TEST_DIR}/project"
  azkfile="$path/${AZK_FILE_NAME}"
  cp_fixture full_azkfile $azkfile

  cd ./project
  run azk-app info
  echo "$output"
  assert_success

  agent_path="$(azk.resolve_app_agent_dir $path)"

  assert_equal "def73023f3b54e5"           $(echo $output | jq -r ".id")
  assert_equal "azk/apps/def73023f3b54e5"  $(echo $output | jq -r ".image")
  assert_equal "azukiapp/test-box#v0.0.1"  $(echo $output | jq -r ".box")
  assert_equal "$path"       $(echo $output | jq -r ".path")
  assert_equal "$azkfile"    $(echo $output | jq -r ".azkfile")
  assert_equal "$agent_path" $(echo $output | jq -r ".agent_path")
}
