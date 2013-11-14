#!/usr/bin/env bats

load ../test_helper

@test "without args shows summary of common commands" {
  run azk-help
  assert_success
  assert_line "Usage: azk <command> [<args>]"
  assert_line "Some useful azk commands are:"
}

@test "invalid command" {
  run azk-help hello
  assert_failure "azk: no such command \`hello'"
}

@test "shows help for a specific command" {
  mkdir -p "${AZK_TEST_DIR}/bin"
  cat > "${AZK_TEST_DIR}/bin/azk-hello" <<SH
#!shebang
# Usage: azk hello <world>
# Summary: Says "hello" to you, from azk
# This command is useful for saying hello.
echo hello
SH

  run azk-help hello
  assert_success
  assert_output <<SH
Usage: azk hello <world>

This command is useful for saying hello.
SH
}

@test "replaces missing extended help with summary text" {
  mkdir -p "${AZK_TEST_DIR}/bin"
  cat > "${AZK_TEST_DIR}/bin/azk-hello" <<SH
#!shebang
# Usage: azk hello <world>
# Summary: Says "hello" to you, from azk
echo hello
SH

  run azk-help hello
  assert_success
  assert_output <<SH
Usage: azk hello <world>

Says "hello" to you, from azk
SH
}

@test "extracts only usage" {
  mkdir -p "${AZK_TEST_DIR}/bin"
  cat > "${AZK_TEST_DIR}/bin/azk-hello" <<SH
#!shebang
# Usage: azk hello <world>
# Summary: Says "hello" to you, from azk
# This extended help won't be shown.
echo hello
SH

  run azk-help --usage hello
  assert_success "Usage: azk hello <world>"
}

@test "multiline usage section" {
  mkdir -p "${AZK_TEST_DIR}/bin"
  cat > "${AZK_TEST_DIR}/bin/azk-hello" <<SH
#!shebang
# Usage: azk hello <world>
#        azk hi [everybody]
#        azk hola --translate
# Summary: Says "hello" to you, from azk
# Help text.
echo hello
SH

  run azk-help hello
  assert_success
  assert_output <<SH
Usage: azk hello <world>
       azk hi [everybody]
       azk hola --translate

Help text.
SH
}

@test "multiline extended help section" {
  mkdir -p "${AZK_TEST_DIR}/bin"
  cat > "${AZK_TEST_DIR}/bin/azk-hello" <<SH
#!shebang
# Usage: azk hello <world>
# Summary: Says "hello" to you, from azk
# This is extended help text.
# It can contain multiple lines.
#
# And paragraphs.

echo hello
SH

  run azk-help hello
  assert_success
  assert_output <<SH
Usage: azk hello <world>

This is extended help text.
It can contain multiple lines.

And paragraphs.
SH
}
