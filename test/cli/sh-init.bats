#!/usr/bin/env bats

load ../test_helper

@test "setup shell completions" {
  root="$(cd $_AZK_PATH && pwd)"
  run azk-sh-init - bash
  assert_success
  assert_line "source '${root}/libexec/../completions/azk.bash'"
}

@test "detect parent shell" {
  root="$(cd $_AZK_PATH && pwd)"
  SHELL=/bin/false run azk-sh-init -
  assert_success
  assert_line "export AZK_SHELL=bash"
}

@test "setup shell completions (fish)" {
  root="$(cd $_AZK_PATH && pwd)"
  run azk-sh-init - fish
  assert_success
  assert_line ". '${root}/libexec/../completions/azk.fish'"
}
