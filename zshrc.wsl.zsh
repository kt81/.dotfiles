# vim: et:ts=2:sw=0:sts=-1:ft=zsh
# ============================================================================
#  WSL-specific configuration
#  Sourced from zshrc.core.zsh only when $WSL_DISTRO_NAME is set.
# ============================================================================

# ----------------------------------------------------------------------------
#  Windows interop PATH
# ----------------------------------------------------------------------------
#  We disable Windows PATH injection in /etc/wsl.conf (appendWindowsPath=false)
#  so command lookup and completion stay fast -- the full Windows PATH adds 50+
#  slow /mnt/c entries. Re-add only the few Windows tools we call from the shell.
#  Override WIN_HOME in ~/.zshrc.local if your Windows user name differs.
: ${WIN_HOME:=/mnt/c/Users/$USER}
typeset -U path                                   # keep PATH de-duplicated
_wsl_paths=(
  /mnt/c/Windows/System32                                    # clip.exe, wsl.exe, cmd, where
  /mnt/c/Windows                                             # explorer.exe
  "$WIN_HOME/AppData/Local/Programs/Microsoft VS Code/bin"   # code
  "/mnt/c/Program Files/Docker/Docker/resources/bin"         # docker (Docker Desktop)
  "/mnt/c/Program Files/PowerShell/7"                        # pwsh
  /mnt/c/tools/neovim/nvim-win64/bin                         # win32yank.exe
)
for _p in $_wsl_paths ; do
  [[ -d $_p ]] && path+=("$_p")
done
unset _wsl_paths _p

# ----------------------------------------------------------------------------
#  Clipboard  (macOS-style pbcopy / pbpaste)
# ----------------------------------------------------------------------------
#  Prefer win32yank (preserves UTF-8 and handles CR/LF); fall back to clip.exe.
if (( $+commands[win32yank.exe] )) ; then
  alias pbcopy='win32yank.exe -i --crlf'
  alias pbpaste='win32yank.exe -o --lf'
elif (( $+commands[clip.exe] )) ; then
  alias pbcopy='clip.exe'
  alias pbpaste='powershell.exe -NoProfile -Command Get-Clipboard | tr -d "\r"'
fi

# ----------------------------------------------------------------------------
#  Open files / URLs with the Windows default application
# ----------------------------------------------------------------------------
#  wslview comes from the `wslu` package. These override the xdg-open based
#  start() defined in zshrc.core.zsh.
if (( $+commands[wslview] )) ; then
  alias open='wslview'
  start() { wslview "$@" ; }
elif (( $+commands[explorer.exe] )) ; then
  alias open='explorer.exe'
  start() { explorer.exe "$@" ; }
fi
alias e.='explorer.exe .'                   # open the current directory in Explorer
