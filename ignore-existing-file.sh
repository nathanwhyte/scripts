#!/bin/bash

for arg in "$@"; do
    if [ ! -f "$arg" ]; then
        echo "$arg not a file, skipping..."
        continue
    elif [ -d "$arg" ]; then
        echo "$arg is a directory, skipping..."
        continue
    fi

    # TODO: get root path of repo

    # TODO: check for .gitingore and .git/info/exclude

    # TODO: check if file is already tracked

    if grep -q "$arg" "$(pwd)"/.gitignore; then
        echo "$arg is already ignored, skipping..."
    fi

    if grep -q "$arg" "$(pwd)"/.git/info/exclude; then
        echo "$arg is already ignored, skipping..."
    fi

    mv "$arg" "$arg.ignore"

    echo "$arg" >>"$(pwd)"/.git/info/exclude

    git add "$arg"
    git commit -m "ingore-existing-file.sh: ignore $arg"
    git show

    mv "$arg.ignore" "$arg"
done
