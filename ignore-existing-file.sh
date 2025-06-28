#!/usr/bin/env bash

PRINT_PADDING="  "

COLOR_RED=$(tput setaf 1)
COLOR_GREEN=$(tput setaf 2)
COLOR_YELLOW=$(tput setaf 3)
STYLE_RESET=$(tput sgr0)

turn_red() {
  printf "%s%s%s" "${COLOR_RED}" "$1" "${STYLE_RESET}"
}

turn_green() {
  printf "%s%s%s" "${COLOR_GREEN}" "$1" "${STYLE_RESET}"
}

turn_yellow() {
  printf "%s%s%s" "${COLOR_YELLOW}" "$1" "${STYLE_RESET}"
}

CHECKMARK="$(turn_green "")"
QUESTION_MARK="$(turn_yellow "?")"
X_MARK="$(turn_red "")"

GIT_DIR="$(git rev-parse --show-toplevel 2>/dev/null)"

printf "\n"

if [[ -z "$GIT_DIR" ]]; then
  printf "  %s Not in a Git repository, exiting...\n" "$X_MARK"
  exit 0
fi

REPO_IGNORE_FILE="$GIT_DIR/.gitignore"
PRIVATE_IGNORE_FILE="$GIT_DIR/.git/info/exclude"

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

declare -a FILES

for arg in "$@"; do
  if [ -f "$arg" ] || [ -d "$arg" ]; then
    # FILES+=("$arg")

    # TODO: check .gitignore and .git/info/exclude content
    if grep -q -s "$arg" "$(pwd)"/.gitignore "$(pwd)"/.git/info/exclude; then
      echo "$arg is already ignored, skipping..."
      continue
    fi

    # if grep -q "$arg" "$(pwd)"/.git/info/exclude; then
    #   echo "$arg is already ignored, skipping..."
    #   continue
    # fi
  else
    printf "%s%s is not a file or directory, skipping...\n" "$PRINT_PADDING" "$(turn_green "\`$arg\`")"
    continue
  fi
done

printf "\n"
