#!/usr/bin/env bash
set -euo pipefail

printf "\n   🧠 Thinking...\n\n"

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

CODEX_RESPONSE=$(codex exec --skip-git-repo-check --json --model "$MODEL" "$FULL_PROMPT")

CODEX_ANSWER=$(echo "$CODEX_RESPONSE" | jq -r '.item.text? // empty')

printf "   %s\n" "$CODEX_ANSWER"
