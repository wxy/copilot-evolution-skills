#!/usr/bin/env bats

# Tests for evoskills update command

source "$(dirname "$BATS_TEST_FILENAME")/test_helper.sh"

setup() {
  TEST_DIR=$(setup_test_dir)
  export TEST_DIR
  
  # Initialize the project first
  cd "$TEST_DIR"
  "$EVOSKILLS_CMD" init --core-only > /dev/null 2>&1
  cd - > /dev/null
}

teardown() {
  if [ -n "$TEST_DIR" ]; then
    cleanup_test_dir "$TEST_DIR"
  fi
}

@test "update command succeeds" {
  run bash -c "cd '$TEST_DIR' && '$EVOSKILLS_CMD' update 2>&1"
  [ $status -eq 0 ]
}

@test "update does not auto-install CLI" {
  run bash -c "cd '$TEST_DIR' && '$EVOSKILLS_CMD' update 2>&1"
  [ $status -eq 0 ]

  [[ "$output" != *"Updating evoskills CLI"* ]]
}

@test "update unconditionally refreshes constitution file" {
  # Modify the constitution file
  echo "MODIFIED" > "$TEST_DIR/.github/AI_CONSTITUTION.md"
  
  # Run update
  run bash -c "cd '$TEST_DIR' && '$EVOSKILLS_CMD' update 2>&1"
  [ $status -eq 0 ]
  
  # File should be updated (not contain our modification)
  [ ! -f "$TEST_DIR/.github/AI_CONSTITUTION.md" ] || ! grep -q "^MODIFIED$" "$TEST_DIR/.github/AI_CONSTITUTION.md"
}

@test "update provides feedback on constitution update" {
  run bash -c "cd '$TEST_DIR' && '$EVOSKILLS_CMD' update 2>&1"
  [ $status -eq 0 ]
  
  # Should mention updating the constitution
  [[ "$output" == *"Updated"* ]] || [[ "$output" == *"Updating"* ]]
}

@test "update unconditionally refreshes initialization file" {
  # Modify the initialization file
  echo "MODIFIED" > "$TEST_DIR/.github/AI_INITIALIZATION.md"
  
  # Run update
  run bash -c "cd '$TEST_DIR' && '$EVOSKILLS_CMD' update 2>&1"
  [ $status -eq 0 ]
  
  # File should be updated
  grep -q "Initialization Protocol" "$TEST_DIR/.github/AI_INITIALIZATION.md"
}

@test "update restores initialization file when remote is unavailable and local file is empty" {
  # Simulate corrupted local file
  : > "$TEST_DIR/.github/AI_INITIALIZATION.md"

  # Set invalid repo to force remote fetch failure
  run bash -c "cd '$TEST_DIR' && '$EVOSKILLS_CMD' update --repo 'https://github.com/invalid/does-not-exist' 2>&1"
  # Command may fail later when refreshing skills from invalid repo, but recovery should still happen

  # Should be recovered from bundled template and remain non-empty
  [ -s "$TEST_DIR/.github/AI_INITIALIZATION.md" ]
  grep -q "Required Initialization Protocol" "$TEST_DIR/.github/AI_INITIALIZATION.md"
}

@test "update refreshes all installed skills" {
  # Modify an already-installed core skill to simulate outdated installation
  echo "MODIFIED" > "$TEST_DIR/.agent/skills/_evolution-core/SKILL.md"
  
  # Run update
  run bash -c "cd '$TEST_DIR' && '$EVOSKILLS_CMD' update 2>&1"
  [ $status -eq 0 ]
  
  # Skill file should be refreshed from remote
  [ -f "$TEST_DIR/.agent/skills/_evolution-core/SKILL.md" ]
  ! grep -q "^MODIFIED$" "$TEST_DIR/.agent/skills/_evolution-core/SKILL.md"
}

@test "update with skill parameter updates only that skill" {
  # Install two skills
  bash -c "cd '$TEST_DIR' && '$EVOSKILLS_CMD' install _git-commit" > /dev/null 2>&1
  bash -c "cd '$TEST_DIR' && '$EVOSKILLS_CMD' install _pr-creator" > /dev/null 2>&1
  
  # Remove _git-commit
  rm -rf "$TEST_DIR/.agent/skills/_git-commit"
  
  # Update only _git-commit
  run bash -c "cd '$TEST_DIR' && '$EVOSKILLS_CMD' update _git-commit"
  [ $status -eq 0 ]
  
  # _git-commit should be reinstalled
  [ -d "$TEST_DIR/.agent/skills/_git-commit" ]
  # _pr-creator should still be there
  [ -d "$TEST_DIR/.agent/skills/_pr-creator" ]
}

@test "update with --repo changes repository" {
  run bash -c "cd '$TEST_DIR' && '$EVOSKILLS_CMD' update --repo 'https://github.com/new/repo' 2>&1"
  
  # Check that config was updated (even if other parts fail)
  [ -f "$TEST_DIR/.evoskills-config.json" ]
  grep -q "https://github.com/new/repo" "$TEST_DIR/.evoskills-config.json"
}

@test "update displays completion message" {
  run bash -c "cd '$TEST_DIR' && '$EVOSKILLS_CMD' update 2>&1"
  [ $status -eq 0 ]
  
  [[ "$output" == *"complete"* ]] || [[ "$output" == *"Complete"* ]]
}

@test "AGENTS.md is updated after update command" {
  run bash -c "cd '$TEST_DIR' && '$EVOSKILLS_CMD' update 2>&1"
  [ $status -eq 0 ]
  
  [ -f "$TEST_DIR/AGENTS.md" ]
  grep -q "_evolution-core" "$TEST_DIR/AGENTS.md"
}
