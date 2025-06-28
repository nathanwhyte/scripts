#!/bin/bash

GIT_DIR="$(git rev-parse --show-toplevel)"

if [[ -z "$GIT_DIR" ]]; then
  echo "Not in a git repository, exiting..."
  exit 1
fi

# TODO: check for .gitingore and .git/info/exclude

# TODO: check if file is already tracked

# TODO: handle directories

# FEAT: interactive mode

declare -a FILES

FILES_IDX=0
for arg in "$@"; do
  if [ ! -f "$arg" ]; then
    echo "$arg not a file, skipping..."
    continue
  elif [ -d "$arg" ]; then
    echo "$arg is a directory, skipping..."
    continue
  fi

  FILES[FILES_IDX]="$arg"
  FILES_IDX=$((FILES_IDX + 1))
done

for arg in "${FILES[@]}"; do
  if grep -q "$arg" "$(pwd)"/.gitignore; then
    echo "$arg is already ignored, skipping..."
  fi

  if grep -q "$arg" "$(pwd)"/.git/info/exclude; then
    echo "$arg is already ignored, skipping..."
  fi

  mv "$arg" "$arg.ignore"

  echo "$arg" >>"$(pwd)"/.git/info/exclude

  git add "$arg"
done

git commit -m "ingore-existing-file.sh: ignore specific files"

for arg in "${FILES[@]}"; do
  mv "$arg.ignore" "$arg"
done
