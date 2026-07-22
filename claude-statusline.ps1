# Claude Code status line — the strip rendered just below the TUI prompt.
#
# Claude Code pipes a JSON blob describing the session to this script on stdin
# and renders whatever we print to stdout. It re-runs on each conversation
# update (debounced ~300ms), so editing this file takes effect on the next
# refresh — no restart. Docs: https://code.claude.com/docs/en/statusline
#
# Two rows:
#   1)  session title · folder · git branch
#   2)  model(effort) · context bar % (used/window) · 5h/7d rate limits
# Context usage is measured against a fixed 1,000,000-token window.
#
# Wire-up in ~/.claude/settings.json  — IMPORTANT: forward slashes in the path.
# On Windows the command runs through Git Bash, which silently eats backslashes:
#   "statusLine": {
#     "type": "command",
#     "command": "pwsh -NoProfile -File C:/Users/kt81/.dotfiles/claude-statusline.ps1"
#   }

$ErrorActionPreference = 'Stop'
$PSNativeCommandUseErrorActionPreference = $false   # a non-zero git exit must not throw
# Force UTF-8 on stdin *before* we read it: launched via Git Bash on a JP-locale
# Windows, PowerShell's console input code page defaults to CP932, which mangles
# the multibyte UTF-8 JSON Claude Code pipes in. Setting InputEncoding here
# re-creates [Console]::In with UTF-8 so the read decodes correctly.
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
try { [Console]::InputEncoding = [System.Text.Encoding]::UTF8 } catch {}

# --- tweakables ----------------------------------------------------------
$TitleGlyph  = '📛'                # name badge ("tofu on fire") — a JP name tag, left of the title
$FolderGlyph = '📁'                # folder marker to the left of the current dir
$ModelGlyph  = '✳️'                # icon at the start of row 2, evoking Claude's sunburst logo
$BranchGlyph = [char]0xE0A0        # nerd-font branch mark; swap for '⎇' or 'git:' if no nerd font
$CtxWindow   = 1000000             # token window that context % is measured against
$BarWidth    = 10                  # width of the context-usage bar, in characters

# --- read the status JSON -------------------------------------------------
# Primary: read stdin (InputEncoding was forced to UTF-8 above). Also accept a
# file path as $args[0] so the older "cat to temp file" wrapper still works.
$raw = ''
if ($args.Count -ge 1 -and (Test-Path -LiteralPath $args[0])) {
    try { $raw = [System.IO.File]::ReadAllText($args[0], [System.Text.Encoding]::UTF8) } catch {}
}
if ([string]::IsNullOrWhiteSpace($raw)) {
    try { $raw = [Console]::In.ReadToEnd() } catch {}
}
try { $ctx = $raw | ConvertFrom-Json } catch { $ctx = $null }

$title = $ctx.session_name                       # AI-generated (or /rename'd) title
$model = $ctx.model.display_name
if (-not $model) { $model = 'Claude' }
$dir   = $ctx.workspace.current_dir
if (-not $dir) { $dir = $ctx.cwd }
$used   = [long]($ctx.context_window.total_input_tokens)  # input+cache_read+cache_creation
$effort = $ctx.effort.level                              # low|medium|high|xhigh|max (may be absent)
$rl5    = $ctx.rate_limits.five_hour.used_percentage     # 0-100 (absent unless Pro/Max, post 1st call)
$rl7    = $ctx.rate_limits.seven_day.used_percentage

# --- git branch (the status JSON has no plain current-branch field) -------
$branch = $null
if ($dir -and (Test-Path -LiteralPath $dir)) {
    $b = (& git -C $dir rev-parse --abbrev-ref HEAD 2>$null)
    if ($LASTEXITCODE -eq 0 -and $b) {
        if ($b -eq 'HEAD') {                     # detached — show a short SHA instead
            $sha = (& git -C $dir rev-parse --short HEAD 2>$null)
            if ($sha) { $branch = "@$sha" }
        } else {
            $branch = $b
        }
    }
}

# --- context-window percentage + usage bar (fixed 1M window) -------------
$pct    = if ($used -gt 0) { [math]::Round($used / $CtxWindow * 100) } else { 0 }
$usedK  = [math]::Round($used / 1000)
$winTxt = '{0:0.#}M' -f ($CtxWindow / 1000000)
$filled = [math]::Max(0, [math]::Min($BarWidth, [math]::Round($pct * $BarWidth / 100)))
$bar    = ('█' * $filled) + ('░' * ($BarWidth - $filled))

# --- colours --------------------------------------------------------------
$e = [char]27
$reset = "$e[0m"; $dim = "$e[2m"; $bold = "$e[1m"
$cyan  = "$e[36m"; $green = "$e[32m"; $yellow = "$e[33m"; $red = "$e[31m"; $mag = "$e[35m"
function Ct($p) { if ($p -ge 80) { $red } elseif ($p -ge 50) { $yellow } else { $green } }  # threshold colour

$sep = " $dim`·$reset "

# --- row 1: title · folder · branch --------------------------------------
$l1 = @()
$l1 += if ($title) { "$TitleGlyph $bold$title$reset" } else { "$TitleGlyph $dim(untitled)$reset" }
if ($dir)    { $l1 += "$FolderGlyph $(Split-Path $dir -Leaf)" }
if ($branch) { $l1 += "$mag$BranchGlyph $branch$reset" }

# --- row 2: model(effort) · context bar · rate limits --------------------
$l2 = @()
$modelSeg = "$ModelGlyph $cyan$model$reset"
if ($effort) { $modelSeg += " $dim($effort)$reset" }
$l2 += $modelSeg
$l2 += "$(Ct $pct)$bar ${pct}%$reset $dim(${usedK}k/${winTxt})$reset"
$rl = @()
if ($null -ne $rl5) { $rl += "5h $(Ct $rl5)$([math]::Round($rl5))%$reset" }
if ($null -ne $rl7) { $rl += "7d $(Ct $rl7)$([math]::Round($rl7))%$reset" }
if ($rl.Count) { $l2 += ($rl -join ' / ') }

[Console]::Out.Write((@(($l1 -join $sep), ($l2 -join $sep)) -join "`n"))
