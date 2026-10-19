#!/usr/bin/env bash
# Build lab-target-scan: the same target as lab-target, with Qwen3 thinking
# always off. Scanners such as garak cap output tokens and cannot send
# `think: false`, so the thinking phase alone uses up the budget and their
# replies come back empty. A "/no_think" in the system prompt is ignored by
# Ollama, so the chat template is patched to behave as if think=false was sent.
# Modelfile stays the single source of truth: rerun this after editing it.
set -euo pipefail
cd "$(dirname "$0")"

base=$(awk '/^FROM /{print $2; exit}' Modelfile)
tmp=$(mktemp ./Modelfile.scan.XXXXXX)
trap 'rm -f "$tmp"' EXIT

template=$(ollama show "$base" --template | sed \
  -e 's/if and \$\.IsThinkSet (eq \$i \$lastUserIdx)/if (eq $i $lastUserIdx)/' \
  -e 's/if \$\.Think -}}/if false -}}/' \
  -e 's/if and \$\.IsThinkSet (not \$\.Think)/if true/')

[ "$(grep -c -e 'if false -}}' -e 'if true -}}' <<<"$template")" -eq 2 ] || {
  echo "Template of $base changed; update the patterns in $0" >&2; exit 1; }

{ cat Modelfile; printf '\nTEMPLATE """%s"""\n' "$template"; } > "$tmp"
ollama create lab-target-scan -f "$tmp"
