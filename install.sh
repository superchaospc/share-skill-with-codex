#!/usr/bin/env bash
# install.sh — one-shot setup for share-skill-with-codex.
#
# Runs the two steps you'd otherwise do by hand:
#   1. --bootstrap : link THIS skill into the agent dirs (so Codex can see it)
#   2. --all       : link every existing Claude Code skill into the agent dirs
#
# Re-running is safe (idempotent). After it finishes, restart Codex (new session)
# so it rescans its skill dirs.

set -euo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"
LINK="$DIR/scripts/link-skill"

echo "▶ Bootstrapping share-skill-with-codex itself…"
"$LINK" --bootstrap

echo
echo "▶ Linking all existing Claude Code skills…"
"$LINK" --all

echo
echo "✅ Done. Restart Codex (open a new session) so it picks up the linked skills."
