#!/usr/bin/env bash

# TODO: flags and options

# TODO: print usage

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

# accounts for different versions of mktemp between MacOS and Linux
make_temp_dir() {
  mktemp -d 2>/dev/null || mktemp -d -t "$1"
}

TEMP_DIR="$(make_temp_dir "ignore-existing-file")"

for arg in "$@"; do
  if [ -f "$arg" ] || [ -d "$arg" ]; then
    if git check-ignore -q "$arg"; then
      printf "%32s is already ignored, skipping ...\n" "$(turn_green "\`$arg\`")"
      continue
    fi

    if [ -d "$arg" ]; then
      mv "$arg" "$TEMP_DIR"
      find . -type f -path "*$arg*/*" -exec git add {} \;
      echo "$arg/" >>"$PRIVATE_IGNORE_FILE"
    else
      mv "$arg" "$TEMP_DIR"
      git add "$arg"
      echo "$arg" >>"$PRIVATE_IGNORE_FILE"
    fi

  else
    printf "%42s is not a file or directory, skipping ...\n" "$(turn_green "\`$arg\`")"
    continue
  fi
done

printf "\nCreating new commit ...\n\n"

git commit

find "$TEMP_DIR" -maxdepth 1 | tail -n +2 | xargs -I {} mv {} "$GIT_DIR"

rm -rf "$TEMP_DIR"
