#!/usr/bin/env bash
# Claude Code status line (Linux/macOS) — POSIX-ish bash + jq port of
# claude-statusline.ps1. Kept byte-for-byte identical in output to the .ps1 so
# the two can be maintained in parallel; the .ps1 stays the Windows renderer.
#
# Why a separate sh version instead of running the .ps1 via pwsh everywhere:
# pwsh has a ~0.18s .NET cold-start floor per invocation, and this script adds
# ~0.25s on top (ConvertFrom-Json + cmdlet autoload). The status line re-runs on
# every conversation update, so that ~0.4s hitch is felt. This bash+jq version
# runs in <0.02s. See the commit message / dotfiles history for the numbers.
#
# Claude Code pipes a JSON blob describing the session on stdin and renders
# stdout. Re-runs on each update (debounced ~300ms). Docs:
# https://code.claude.com/docs/en/statusline
#
# Wire-up in ~/.claude/settings.json:
#   "statusLine": {
#     "type": "command",
#     "command": "bash \"$HOME/.dotfiles/claude-statusline.sh\""
#   }
#
# NOTE: a status line must never hard-fail (a non-zero exit blanks the line), so
# this script avoids `set -e`; a missing git / bad JSON degrades quietly.

# --- tweakables ----------------------------------------------------------
TitleGlyph='📛'          # name badge ("tofu on fire") — left of the title
FolderGlyph='📁'         # folder marker to the left of the current dir
ModelGlyph='✳️'          # icon at the start of row 2, evoking Claude's logo
BranchGlyph=$''    # nerd-font branch mark; swap for '⎇' or 'git:' if none
CtxWindow=1000000        # token window that context % is measured against
BarWidth=10              # width of the context-usage bar, in characters

# --- read the status JSON -------------------------------------------------
# Primary: stdin. Also accept a file path as $1 so an older "cat to temp file"
# wrapper still works (mirrors the .ps1).
raw=""
if [ -n "${1:-}" ] && [ -f "$1" ]; then raw=$(cat "$1" 2>/dev/null); fi
[ -z "$raw" ] && raw=$(cat)

# One jq pass; fields joined by US (0x1f), a non-whitespace delimiter that won't
# appear in the data and (unlike a tab) won't collapse empty fields on read.
fields=$(printf '%s' "$raw" | jq -r '
  def s: if . == null then "" else tostring end;
  [ (.session_name|s),
    (.model.display_name|s),
    ((.workspace.current_dir // .cwd)|s),
    ((.context_window.total_input_tokens // 0)|s),
    (.effort.level|s),
    (.rate_limits.five_hour.used_percentage|s),
    (.rate_limits.seven_day.used_percentage|s)
  ] | join("")' 2>/dev/null)
IFS=$'\037' read -r title model dir used effort rl5 rl7 <<EOF
$fields
EOF
[ -z "$model" ] && model="Claude"
[ -z "$used" ] && used=0

# --- git branch (the status JSON has no plain current-branch field) -------
branch=""
if [ -n "$dir" ] && [ -d "$dir" ]; then
    b=$(git -C "$dir" rev-parse --abbrev-ref HEAD 2>/dev/null)
    if [ -n "$b" ]; then
        if [ "$b" = "HEAD" ]; then                 # detached — show a short SHA
            sha=$(git -C "$dir" rev-parse --short HEAD 2>/dev/null)
            [ -n "$sha" ] && branch="@$sha"
        else
            branch="$b"
        fi
    fi
fi

# --- context-window percentage + usage bar (fixed 1M window) -------------
pct=$(awk -v u="$used" -v w="$CtxWindow" 'BEGIN{u=u+0; if(u>0) printf "%.0f", u/w*100; else printf "0"}')
usedK=$(awk -v u="$used" 'BEGIN{printf "%.0f", (u+0)/1000}')
winTxt=$(awk -v w="$CtxWindow" 'BEGIN{v=w/1000000; s=sprintf("%.1f",v); sub(/\.0$/,"",s); printf "%sM", s}')
filled=$(awk -v p="$pct" -v b="$BarWidth" 'BEGIN{f=int(p*b/100+0.5); if(f<0)f=0; if(f>b)f=b; print f}')
bar=""
i=0;       while [ "$i" -lt "$filled" ];   do bar="$bar█"; i=$((i+1)); done
i="$filled"; while [ "$i" -lt "$BarWidth" ]; do bar="$bar░"; i=$((i+1)); done

# --- colours --------------------------------------------------------------
e=$'\033'
reset="${e}[0m"; dim="${e}[2m"; bold="${e}[1m"
cyan="${e}[36m"; green="${e}[32m"; yellow="${e}[33m"; red="${e}[31m"; mag="${e}[35m"
ct() { if [ "$1" -ge 80 ]; then printf '%s' "$red"; elif [ "$1" -ge 50 ]; then printf '%s' "$yellow"; else printf '%s' "$green"; fi; }

sep=" ${dim}·${reset} "
join_by() { local d=$1; shift; [ "$#" -eq 0 ] && return; local out=$1; shift; local x; for x in "$@"; do out="$out$d$x"; done; printf '%s' "$out"; }

# --- row 1: title · folder · branch --------------------------------------
l1=()
if [ -n "$title" ]; then l1+=("$TitleGlyph ${bold}${title}${reset}"); else l1+=("$TitleGlyph ${dim}(untitled)${reset}"); fi
[ -n "$dir" ]    && l1+=("$FolderGlyph $(basename "$dir")")
[ -n "$branch" ] && l1+=("${mag}${BranchGlyph} ${branch}${reset}")

# --- row 2: model(effort) · context bar · rate limits --------------------
modelSeg="$ModelGlyph ${cyan}${model}${reset}"
[ -n "$effort" ] && modelSeg="$modelSeg ${dim}(${effort})${reset}"
l2=("$modelSeg")
l2+=("$(ct "$pct")${bar} ${pct}%${reset} ${dim}(${usedK}k/${winTxt})${reset}")
rl=()
if [ -n "$rl5" ]; then rl5r=$(awk -v x="$rl5" 'BEGIN{printf "%.0f", x+0}'); rl+=("5h $(ct "$rl5r")${rl5r}%${reset}"); fi
if [ -n "$rl7" ]; then rl7r=$(awk -v x="$rl7" 'BEGIN{printf "%.0f", x+0}'); rl+=("7d $(ct "$rl7r")${rl7r}%${reset}"); fi
[ "${#rl[@]}" -gt 0 ] && l2+=("$(join_by ' / ' "${rl[@]}")")

printf '%s\n%s' "$(join_by "$sep" "${l1[@]}")" "$(join_by "$sep" "${l2[@]}")"
