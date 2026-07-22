#
# PowerShell profile (tracked by dotfiles; symlinked into $PROFILE).
#
# Mirrors the philosophy of zshrc.core.zsh: every external tool is guarded by a
# "does the command exist?" check, so a machine missing a tool degrades quietly
# instead of throwing on every prompt. Machine-specific tweaks live in
# ~/.profile.mine.ps1 (sourced at the end), never here.
#

# ----------------------------------
# helpers
# ----------------------------------
function Test-Cmd { param([string]$Name) [bool](Get-Command $Name -ErrorAction SilentlyContinue) }

# ----------------------------------
# console: force UTF-8 (Japanese Windows still defaults to legacy CP932,
# which mojibakes Nerd Font glyphs and modern CLI output)
# ----------------------------------
$OutputEncoding = [System.Text.UTF8Encoding]::new()
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()
[Console]::InputEncoding  = [System.Text.UTF8Encoding]::new()

# ----------------------------------
# PSReadLine — vi mode + zsh-autosuggestions-style predictions
# ----------------------------------
Set-PSReadLineOption -EditMode vi
Set-PSReadLineOption -HistorySearchCursorMovesToEnd
# Predictions need a live (non-redirected) console; skip when output is piped or
# redirected (some IDE terminals, `pwsh -Command ... 2>&1`, etc.).
if (-not [Console]::IsOutputRedirected) {
    Set-PSReadLineOption -PredictionSource HistoryAndPlugin
    Set-PSReadLineOption -PredictionViewStyle ListView
}

# Emacs-style line motion, even in vi insert mode
Set-PSReadLineKeyHandler -Chord Ctrl+a -ScriptBlock { [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition(0) }
Set-PSReadLineKeyHandler -Chord Ctrl+e -ScriptBlock { [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition([Int32]::MaxValue) }
Set-PSReadLineKeyHandler -Chord "Ctrl+[" -ScriptBlock { [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition(0) }

# ----------------------------------
# fzf integration (PSFzf) — Ctrl+t files. Ctrl+r is left to atuin (below).
# ----------------------------------
if ((Test-Cmd fzf) -and (Get-Module -ListAvailable PSFzf)) {
    Import-Module PSFzf
    Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t'
    Set-PsFzfOption -TabExpansion
}

# ----------------------------------
# prompt: starship (config shared with zsh via ~/.dotfiles/starship.toml)
# ----------------------------------
$env:STARSHIP_CONFIG = Join-Path $HOME ".dotfiles" "starship.toml"
if (Test-Cmd starship) { starship init powershell | Out-String | Invoke-Expression }

# ----------------------------------
# mise — runtime version manager (node/python/ruby/...), honors .tool-versions
# ----------------------------------
if (Test-Cmd mise) { mise activate pwsh | Out-String | Invoke-Expression }

# ----------------------------------
# zoxide — smart cd (replaces ZLocation); provides `z` / `zi`
# ----------------------------------
if (Test-Cmd zoxide) { zoxide init powershell | Out-String | Invoke-Expression }

# ----------------------------------
# atuin — SQLite-backed shell history (Ctrl+r). Init LAST so it owns Ctrl+r;
# up-arrow stays on PSReadLine. Config shared with zsh.
# ----------------------------------
$env:ATUIN_CONFIG_DIR = Join-Path $HOME ".dotfiles" "atuin"
if (Test-Cmd atuin) { atuin init powershell --disable-up-arrow | Out-String | Invoke-Expression }

# ----------------------------------
# aliases
# ----------------------------------
# editor -> neovim
if (Test-Cmd nvim) {
    Set-Alias vim nvim
    Set-Alias vi  nvim
    $env:EDITOR = 'nvim'
}

# ls -> eza
if (Test-Cmd eza) {
    function ls { eza -F @args }
    function ll { eza -alF @args }
    function la { eza -aF @args }
}

# ----------------------------------
# pager -> ov (bat and friends page through it; git keeps its own pager, delta)
# ----------------------------------
if (Test-Cmd ov) {
    $env:PAGER = 'ov'
    $env:MANPAGER = 'ov'
}

# ----------------------------------
# local, machine-specific settings (tool installers, secrets, per-host tweaks)
# ----------------------------------
if (Test-Path ~/.profile.mine.ps1) {
    . ~/.profile.mine.ps1
    Write-Verbose "Local profile loaded: ~/.profile.mine.ps1"
}
