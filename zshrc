##### Core paths & platform detection #########################################
export DOTFILES_PATH="$HOME/personal/dotfiles"
export ZSH="${ZSH:-$HOME/.oh-my-zsh}"

case "$OSTYPE" in
  darwin*)   export PLATFORM="macOS" ;;
  linux*)    export PLATFORM="Linux" ;;
  *)         export PLATFORM="Unknown" ;;
esac

# Ensure Homebrew is on PATH (esp. Apple Silicon Macs)
if [[ "$PLATFORM" == "macOS" ]]; then
  if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [ -x /usr/local/bin/brew ]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
fi

##### Editor ##################################################################
export EDITOR="nvim"
export SUDO_EDITOR="nvim"

##### PATH (minimal + portable) ###############################################
# Start from whatever shell gave us, then add known user tools
# (Remove Linux-only system paths; add only if present)
path_add() { [ -d "$1" ] && export PATH="$1:$PATH"; }

# Common user bins
path_add "$HOME/.local/bin"
path_add "$HOME/bin"

# Tmuxifier
path_add "$HOME/.tmuxifier/bin"

# Go toolchain (prefer Homebrew on mac; fallback to manual)
if command -v brew >/dev/null 2>&1 && brew list --versions go >/dev/null 2>&1; then
  export GOROOT="$(brew --prefix go)/libexec"
else
  # Fallback if you install Go manually
  export GOROOT="/usr/local/go"
fi
export GOPATH="$HOME/go"
path_add "$GOPATH/bin"
path_add "$GOROOT/bin"

# PNPM (platform-specific default locations)
if [[ "$PLATFORM" == "macOS" ]]; then
  export PNPM_HOME="$HOME/Library/pnpm"
else
  export PNPM_HOME="$HOME/.local/share/pnpm"
fi
path_add "$PNPM_HOME"

# Bun runtime
export BUN_INSTALL="$HOME/.bun"
path_add "$BUN_INSTALL/bin"

##### Node Version Manager (NVM) ##############################################
export NVM_DIR="$HOME/.nvm"
# Load nvm if present
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
# Optional: nvm bash_completion also works in zsh if present
[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"

##### Prompt: oh-my-posh (guarded) ############################################
# Use the theme inside your repo (adjust if your file lives elsewhere)
if command -v oh-my-posh >/dev/null 2>&1 && [ -f "$DOTFILES_PATH/ohmyposh.toml" ]; then
  eval "$(oh-my-posh init zsh --config "$DOTFILES_PATH/ohmyposh.toml")"
fi

##### Tmuxifier (guarded) #####################################################
if command -v tmuxifier >/dev/null 2>&1; then
  eval "$(tmuxifier init -)"
fi

##### Shell options / keybindings ############################################
setopt no_beep
unsetopt BEEP

# vi-mode via plugin (you also set a custom jk escape)
INSERT_MODE_INDICATOR="%F{yellow}+%f"
bindkey -M viins 'jk' vi-cmd-mode

##### Oh My Zsh config ########################################################
# Ensure ZSH_CUSTOM is sane
export ZSH_CUSTOM="${ZSH_CUSTOM:-$ZSH/custom}"

# Plugins you want (make sure you cloned them into $ZSH_CUSTOM/plugins)
plugins=(git vi-mode zsh-autosuggestions zsh-syntax-highlighting)

# Load OMZ
if [ -s "$ZSH/oh-my-zsh.sh" ]; then
  source "$ZSH/oh-my-zsh.sh"
fi

# Place syntax highlighting LAST to avoid conflicts
if [ -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
  source "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi
if [ -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
  source "$ZSH_CUSTOM/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi

##### Completions (guarded) ###################################################
# kubectl
if command -v kubectl >/dev/null 2>&1; then
  source <(kubectl completion zsh)
fi

# Angular CLI
if command -v ng >/dev/null 2>&1; then
  source <(ng completion script)
fi

# mc completion (Homebrew installs mc to brew --prefix)/bin/mc usually)
if command -v mc >/dev/null 2>&1; then
  autoload -U +X bashcompinit && bashcompinit
  complete -o nospace -C "$(command -v mc)" mc
fi

##### Aliases #################################################################
alias config="nvim ~/dotfiles"  # (adjust if you want your repo path)
alias python="python3"
alias pip="pip3"
alias ta="tmux attach"
alias ts="tmux-sessionizer"
alias kube="kubectl -n solutions"
alias lg="lazygit"

##### Auto-start tmux (guarded) ###############################################
if [ -z "$TMUX" ] && [ -x "$DOTFILES_PATH/tmux-home.sh" ]; then
  "$DOTFILES_PATH/tmux-home.sh"
fi

##### Linux-only bits (kept but isolated) #####################################
if [[ "$PLATFORM" == "Linux" ]]; then
  # Flyctl path from your Linux setup (on macOS use brew install flyctl)
  export FLYCTL_INSTALL="$HOME/.fly"
  path_add "$FLYCTL_INSTALL/bin"

  # Bun completion path (Linux-style example you had; mac uses $HOME)
  [ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

  # Cursor setup alias (Linux path from your example)
  alias cursor-setup="$HOME/cursor-setup-wizard/cursor_setup.sh"
fi

export PATH="$HOME/bin:$PATH"

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/bhushanalhat/Downloads/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/bhushanalhat/Downloads/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/bhushanalhat/Downloads/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/bhushanalhat/Downloads/google-cloud-sdk/completion.zsh.inc'; fi

# Added by Antigravity
export PATH="/Users/bhushanalhat/.antigravity/antigravity/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

# Added by Antigravity
export PATH="/Users/bhushanalhat/.antigravity/antigravity/bin:$PATH"
export PATH="/Library/TeX/texbin:$PATH"
