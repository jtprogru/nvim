#!/usr/bin/env bash
# Automated profiling run: open files in a headless nvim with the full config,
# wait for every language server to go quiet, optionally simulate typing, and
# print a report + write JSON.
#
#   scripts/profile.sh README.md
#   scripts/profile.sh --edits 20 note.md              # reproduce the typing storm
#   scripts/profile.sh --vault 15                      # 15 random notes from the Obsidian vault
#   scripts/profile.sh --dir ~/notes --sample 10 --edits 10
#
# Options:
#   -n, --sample N     pick N files at random from --dir / --vault
#   -d, --dir PATH     directory to sample markdown from
#       --vault [N]    shorthand for --dir "$OBSIDIAN_VAULT" --sample N (default 10)
#   -e, --edits N      simulated keystrokes per file (default 0)
#   -w, --wait MS      max wait per file (default 15000)
#   -s, --settle MS    quiet period before a file counts as settled (default 1500)
#   -o, --out PATH     JSON output path
#   -g, --glob PAT     find(1) -name pattern when sampling (default '*.md')
#       --lua          also run the LuaJIT sampling profiler (attributes stalls
#                      to Lua frames; adds a few % of overhead)
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
NVIM="${NVIM:-nvim}"
VAULT="${OBSIDIAN_VAULT:-$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/SecondBrain}"

SAMPLE="" DIR="" GLOB='*.md'
export PROFILE_EDITS="${PROFILE_EDITS:-0}"
export PROFILE_WAIT="${PROFILE_WAIT:-15000}"
export PROFILE_SETTLE="${PROFILE_SETTLE:-1500}"
export PROFILE_OUT="${PROFILE_OUT:-}"

FILES=()
while [ $# -gt 0 ]; do
  case "$1" in
    -n|--sample)  SAMPLE="$2"; shift 2 ;;
    -d|--dir)     DIR="$2"; shift 2 ;;
    --vault)      DIR="$VAULT"
                  case "${2:-}" in ''|-*) SAMPLE=10; shift ;; *) SAMPLE="$2"; shift 2 ;; esac ;;
    -e|--edits)   PROFILE_EDITS="$2"; shift 2 ;;
    -w|--wait)    PROFILE_WAIT="$2"; shift 2 ;;
    -s|--settle)  PROFILE_SETTLE="$2"; shift 2 ;;
    -o|--out)     PROFILE_OUT="$2"; shift 2 ;;
    -g|--glob)    GLOB="$2"; shift 2 ;;
    --lua)        export NVIM_PROFILE_SAMPLE=1; shift ;;
    -h|--help)    sed -n '2,24p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit 0 ;;
    --)           shift; break ;;
    -*)           echo "unknown option: $1" >&2; exit 2 ;;
    *)            FILES+=("$1"); shift ;;
  esac
done
FILES+=("$@")

if [ -n "$SAMPLE" ]; then
  [ -d "$DIR" ] || { echo "not a directory: $DIR" >&2; exit 2; }
  while IFS= read -r f; do FILES+=("$f"); done < <(
    find "$DIR" -type f -name "$GLOB" ! -path '*/.git/*' ! -path '*/.obsidian/*' \
      | sort -R | head -n "$SAMPLE"
  )
fi

[ ${#FILES[@]} -gt 0 ] || { echo "no files to profile — pass paths or --sample N" >&2; exit 2; }

echo "==> profiling ${#FILES[@]} file(s) with $($NVIM --version | head -1)"
NVIM_PROFILE=1 "$NVIM" --headless "${FILES[@]}" \
  -c "luafile $HERE/scripts/profile_run.lua"
