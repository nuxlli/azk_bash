#!/usr/bin/env bats

load ../test_helper

@test "blank invocation" {
  run azk
  assert_success
  assert [ "${lines[0]}" = "azk 0.1.0" ]
}
