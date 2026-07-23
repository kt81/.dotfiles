# Brewfile — managed base environment for macOS (tracked by dotfiles).
#
#   brew bundle --file=Brewfile
#
# Machine-specific / stack extras live in Brewfile.local (untracked).

# --- shell & editor ---
brew "zsh"
brew "tmux"
brew "neovim"
brew "tree-sitter" # CLI to build nvim-treesitter parsers (main branch needs it)
brew "starship"   # cross-shell prompt (replaces powerlevel10k)

# --- modern CLI ---
brew "ripgrep"    # rg  — grep
brew "fd"         #     — find
brew "eza"        #     — ls
brew "bat"        #     — cat + syntax highlight
brew "ov"         #     — feature-rich pager ($PAGER); less alternative
brew "git-delta"  # delta — git diff pager
brew "fzf"        #     — fuzzy finder
brew "zoxide"     #     — smart cd (successor to zsh-z)
brew "atuin"      #     — SQLite-backed shell history (Ctrl-R), local-only
brew "jq"

# --- VCS ---
brew "git"
brew "git-lfs"
brew "gh"         # GitHub CLI
brew "tig"        # git history / log browser

# --- system / monitor ---
brew "htop"
brew "btop"

# --- base utils ---
brew "curl"
brew "wget"
brew "coreutils"
brew "gnupg"
brew "unzip"
brew "bash"

# --- runtime / task ---
brew "mise"       # runtime version manager (node/python/ruby/...) — replaces asdf + nvm
brew "go-task"    # Taskfile runner
brew "pstree"

# --- data ---
brew "redis"
brew "mysql-client"

# --- fonts ---
cask "font-hackgen"
cask "font-hackgen-nerd"
