#!/bin/zsh

# zsh completion function for the 'gradlew' command.
#
# EXAMPLE USAGE:
#   1. Type `gradlew ` (with a space) in your terminal.
#   2. Press the <Tab> key.
#   3. A list of available tasks will be displayed with descriptions.
#
# EXAMPLE COMPLETION OUTPUT:
#   $ gradlew <Tab>
#   -- gradle task --
#   build   -- Assembles and tests this project.
#   clean   -- Deletes the build directory.
#   test    -- Runs the unit tests.
#
_gradlew_completion() {
  # Find the 'gradlew' executable file in the current directory.
  # Using -maxdepth 1 to prevent searching in subdirectories for performance.
  local gradlew_path
  gradlew_path=$(find . -name 'gradlew' -type f -maxdepth 1)

  # If 'gradlew' is not found, display a message and stop.
  if [ ! -f "$gradlew_path" ]; then
    _message "No gradlew found in current directory"
    return 1
  fi

  # --- Primary Strategy: Parse tasks with descriptions ---
  # This provides a richer completion experience, showing what each task does.

  local -a completions
  # Set the Internal Field Separator (IFS) to newline only.
  # This is crucial for correctly reading lines that contain spaces into an array.
  local IFS=$'\n'
  completions=( $(
    ./"$gradlew_path" tasks --all --console=plain |
    grep -- ' - ' |
    awk '{match($0, / - /); task = substr($0, 1, RSTART - 1); desc = substr($0, RSTART + 3); gsub(/:/, "\\:", task); printf "%s:%s\n", task, desc;}'
  ) )
  # Restore the original IFS to avoid side effects.
  unset IFS

  # If the 'completions' array was successfully populated, use _describe to show tasks with descriptions.
  if [ ${#completions[@]} -gt 0 ]; then
    _describe 'gradle task' completions
  else
    # --- Fallback Strategy: Parse task names only ---
    # This is used if the primary strategy fails (e.g., a Gradle version with unusual output format).
    reply=( $(
      ./"$gradlew_path" tasks --all --console=plain |
      # Filter for lines that likely start with a task name.
      grep -E '^[a-zA-Z]' |
      # Extract the first word from each line, which is assumed to be the task name.
      awk '{print $1}'
    ) )
    # If the fallback also fails to find any tasks, show an error message.
    if [ ${#reply[@]} -eq 0 ]; then
      _message "No gradle tasks found"
      return 1
    fi
  fi
}

compdef _gradlew_completion gradlew