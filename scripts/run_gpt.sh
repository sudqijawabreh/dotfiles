#!/usr/bin/env bash
#set -euo pipefail

# --- Clipboard helpers (Linux/macOS) ---
get_clipboard() {
  if command -v pbpaste >/dev/null 2>&1; then
    pbpaste
  elif command -v wl-paste >/dev/null 2>&1; then
    wl-paste
  elif command -v xclip >/dev/null 2>&1; then
    xclip -selection clipboard -o
  elif command -v xsel >/dev/null 2>&1; then
    xsel --clipboard --output
  else
    echo "No clipboard tool found (need pbpaste, wl-paste, xclip, or xsel)." >&2
    exit 1
  fi
}

set_clipboard() {
  if command -v pbcopy >/dev/null 2>&1; then
    pbcopy
  elif command -v wl-copy >/dev/null 2>&1; then
    wl-copy
  elif command -v xclip >/dev/null 2>&1; then
    xclip -selection clipboard -i
  elif command -v xsel >/dev/null 2>&1; then
    xsel --clipboard --input
  else
    echo "No clipboard tool found to write (need pbcopy, wl-copy, xclip, or xsel)." >&2
    exit 1
  fi
}

ORIG_TEXT="$(get_clipboard)"

# Guardrails
if [[ -z "${ORIG_TEXT//[[:space:]]/}" ]]; then
  echo "Clipboard is empty." >&2
  exit 1
fi

# Build a single-string instruction for Codex exec.
# (We embed the clipboard content between <<< >>> and ask for ONLY corrected text.)
read -r -d '' PROMPT <<'P_END'
You are a professional copy editor. Improve grammar, spelling, punctuation, and clarity.
Rules:
- Preserve meaning and tone.
- Keep line breaks and Markdown formatting.
- Do NOT add explanations or quotes—output ONLY the corrected text.
- Do NOT modify code blocks, inline code, or URLs.
Text to edit is between <<< and >>>.
P_END

# Safely append the dynamic text
PROMPT+="

<<<
${ORIG_TEXT}
>>>"

# Run Codex in non-interactive mode and capture the corrected text.
# Note: 'codex exec' runs a single instruction and prints the result to stdout.
FIXED_TEXT="$(codex exec "$PROMPT")"

# Write back to clipboard
printf "%s" "$FIXED_TEXT" | set_clipboard

# Optional UX: brief confirmation to stderr so it doesn't pollute the clipboard.
echo "✅ Clipboard text cleaned up with Codex." >&2
