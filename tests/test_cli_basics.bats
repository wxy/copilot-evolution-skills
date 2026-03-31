#!/usr/bin/env bats

# Tests for evoskills CLI basics

source "$(dirname "$BATS_TEST_FILENAME")/test_helper.sh"

@test "version flag shows current version" {
  output=$("$EVOSKILLS_CMD" --version 2>&1)
  expected_version=$(grep '^CLI_VERSION=' "$EVOSKILLS_CMD" | sed 's/CLI_VERSION="\(.*\)"/\1/')
  [[ "$output" == *"$expected_version"* ]]
}

@test "version short flag -v shows current version" {
  output=$("$EVOSKILLS_CMD" -v 2>&1)
  expected_version=$(grep '^CLI_VERSION=' "$EVOSKILLS_CMD" | sed 's/CLI_VERSION="\(.*\)"/\1/')
  [[ "$output" == *"$expected_version"* ]]
}

@test "help flag displays usage information" {
  output=$("$EVOSKILLS_CMD" --help 2>&1)
  [[ "$output" == *"evoskills - Evolution Skills CLI"* ]]
  [[ "$output" == *"Commands:"* ]]
}

@test "help short flag -h displays usage information" {
  output=$("$EVOSKILLS_CMD" -h 2>&1)
  [[ "$output" == *"evoskills - Evolution Skills CLI"* ]]
}

@test "no arguments shows help" {
  output=$("$EVOSKILLS_CMD" 2>&1)
  [[ "$output" == *"Usage:"* ]]
}

@test "invalid command shows error" {
  run "$EVOSKILLS_CMD" invalid-command 2>&1
  [ $status -ne 0 ]
  [[ "$output" == *"Unknown command"* ]]
}

@test "evoskills script exists and is executable" {
  [ -x "$EVOSKILLS_CMD" ]
}

@test "evoskills script has shebang" {
  head -1 "$EVOSKILLS_CMD" | grep -q "#!/bin/bash"
}
