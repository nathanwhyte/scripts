#!/usr/bin/env bash

PRINT_PADDING="  "

COLOR_GREEN=$(tput setaf 2)
COLOR_YELLOW=$(tput setaf 3)
STYLE_RESET=$(tput sgr0)

turn_green() {
  printf "%s%s%s" "${COLOR_GREEN}" "$1" "${STYLE_RESET}"
}

turn_yellow() {
  printf "%s%s%s" "${COLOR_YELLOW}" "$1" "${STYLE_RESET}"
}

CHECKMARK="$(turn_green "")"
QUESTION_MARK="$(turn_yellow "?")"

GIT_DIR="$(git rev-parse --show-toplevel)"

REPO_IGNORE_FILE="$GIT_DIR/.gitignore"
PRIVATE_IGNORE_FILE="$GIT_DIR/.git/info/exclude"

printf "\n"

if [ -f "$PRIVATE_IGNORE_FILE" ]; then
  printf "%s%s Found \`.git/info/exclude\`\n" "$PRINT_PADDING" "$CHECKMARK"
else
  printf "%s%s Didn't find \`.git/info/exclude\`\n" "$PRINT_PADDING" "$QUESTION_MARK"
fi

if [ -f "$REPO_IGNORE_FILE" ]; then
  printf "%s%s Found \`.gitignore\`\n" "$PRINT_PADDING" "$CHECKMARK"
else
  printf "%s%s Didn't find \`.gitignore\`\n" "$PRINT_PADDING" "$QUESTION_MARK"
fi

printf "\n"

if [[ -z "$GIT_DIR" ]]; then
  echo "Not in a git repository, exiting..."
  exit 1
fi

declare -a FILES

for arg in "$@"; do
  if [ -f "$arg" ] || [ -d "$arg" ]; then
    FILES+=("$arg")
  else
    printf "%s%s is not a file or directory, skipping...\n" "$PRINT_PADDING" "$(turn_green "\`$arg\`")"
    continue
  fi
done

printf "\n"
