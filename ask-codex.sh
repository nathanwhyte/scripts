#!/usr/bin/env bash
set -euo pipefail

printf "\n 🧠 Thinking...\n\n"

SYSTEM_INSTRUCTIONS=$(
  cat <<'EOF'
You are a CLI assistant that provides brief answers to questions from the user.

Rules:
- Follow instructions exactly.
- Answer only the question provided.
- Keep responses concise and to the point.
- Do not modify or create files unless prompted to do so.
- Do not output explanations or additional information beyond what is requested.
- Only output the answer to the question and related information, nothing more.
- Answers should be in plain text. No markdown or rich text formatting.
EOF
)

PREBUILT_PROMPT=$(
  cat <<'EOF'
Context:
You are operating on a developer workstation.
Assume standard Unix tools are available.
EOF
)

if [[ $# -eq 0 ]]; then
  echo "Usage: $0 <question>" >&2
  exit 1
fi

USER_INPUT="$*"

FULL_PROMPT=$(
  cat <<EOF
$SYSTEM_INSTRUCTIONS

$PREBUILT_PROMPT

User input:
$USER_INPUT
EOF
)

MODEL="gpt-5.2"
EFFORT="low"

CODEX_RESPONSE=$(codex exec --skip-git-repo-check --config model_reasoning_effort="$EFFORT" --json --model "$MODEL" "$FULL_PROMPT")

OUTPUT_BIN="$(which cat)"
if [ "$(whereis rich | wc -w)" -eq 1 ]; then
  printf "This script uses 'rich' for nicer-looking output, but it wasn't found on your machine.\n"
  printf "Check it out at %s\n" "https://github.com/textualize/rich-cli"
  OUTPUT_FLAGS=""
else
  OUTPUT_BIN="$(whereis rich | awk '{print $2}')"
  OUTPUT_FLAGS="--panel=rounded"
fi

printf "\n 🤖 ChatGPT says:\n"

# use printf/echo twice to automatically handle trailing/leading newlines
"$OUTPUT_BIN" <(printf "%s" "$(echo "$CODEX_RESPONSE" | jq -r '.item.text? // empty')") "$OUTPUT_FLAGS"
