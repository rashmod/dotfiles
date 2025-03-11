# If you come from Bash, you might need to update your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation
export ZSH="$HOME/.oh-my-zsh"

# Set default editor to Neovim
export EDITOR='nvim'

# Add various directories to $PATH to ensure executables are found
export PATH="$PATH:/root/.local/bin"
export PATH="$PATH:/snap/bin"
export PATH="$PATH:/usr/local/bin"
export PATH="$PATH:/home/rashmod/.local/bin"

# Add Tmuxifier to $PATH
export PATH="$HOME/.tmuxifier/bin:$PATH"

# Configure Fly.io CLI path
export FLYCTL_INSTALL="/home/rashmod/.fly"
export PATH="$FLYCTL_INSTALL/bin:$PATH"

# Set up Go environment variables
export GOROOT=/usr/local/go
export GOPATH=$HOME/go
export PATH=$GOPATH/bin:$GOROOT/bin:$PATH

# Load Node Version Manager (NVM) if installed
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # Load nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # Load bash completion for nvm

# Load Oh My Posh with a custom theme
eval "$(oh-my-posh init zsh --config $HOME/dotfiles/ohmyposh.toml)"

# Initialize Tmuxifier
eval "$(tmuxifier init -)"

# Disable terminal beep sounds
setopt no_beep
unsetopt BEEP

# Enable vi mode in terminal and set an indicator for insert mode
INSERT_MODE_INDICATOR="%F{yellow}+%f"
bindkey -M viins 'jk' vi-cmd-mode  # Press 'jk' in insert mode to switch to normal mode

# Configure Oh My Zsh theme (commented out by default)
# ZSH_THEME="agnoster"

# Allow using a list of themes randomly (if ZSH_THEME is set to "random")
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment to enable case-sensitive completion
# CASE_SENSITIVE="true"

# Uncomment to allow treating hyphens and underscores as interchangeable in completion
# HYPHEN_INSENSITIVE="true"

# Configure Oh My Zsh update behavior (commented out by default)
# zstyle ':omz:update' mode disabled  # Disable automatic updates
# zstyle ':omz:update' mode auto      # Update automatically without asking
# zstyle ':omz:update' mode reminder  # Remind me to update

# Uncomment to set auto-update frequency (in days)
# zstyle ':omz:update' frequency 13

# Uncomment if pasting URLs and other text is causing issues
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment to disable color in `ls`
# DISABLE_LS_COLORS="true"

# Uncomment to disable automatic terminal title updates
# DISABLE_AUTO_TITLE="true"

# Uncomment to enable automatic command correction
# ENABLE_CORRECTION="true"

# Uncomment to show a visual indicator while waiting for autocompletion
# COMPLETION_WAITING_DOTS="true"

# Uncomment to speed up repository checks in large Git repositories
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment to customize the timestamp format in `history`
# HIST_STAMPS="yyyy-mm-dd"

# Custom folder for Oh My Zsh configurations (if needed)
# ZSH_CUSTOM=/path/to/new-custom-folder

# Plugins to load in Oh My Zsh
# Standard plugins are found in $ZSH/plugins/
# Custom plugins can be added in $ZSH_CUSTOM/plugins/
plugins=(git vi-mode zsh-autosuggestions zsh-syntax-highlighting)

# Enable Kubernetes autocompletion
source <(kubectl completion zsh)

# Load Oh My Zsh
source $ZSH/oh-my-zsh.sh

# User configuration (custom exports and settings)

# Uncomment and update to manually set language environment
# export LANG=en_US.UTF-8

# Set preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi

# Compilation flags (for macOS or specific architectures)
# export ARCHFLAGS="-arch $(uname -m)"

# Define personal aliases
alias zshconfig="nvim ~/dotfiles/zshrc"  # Quickly edit Zsh config
# alias ohmyzsh="mate ~/.oh-my-zsh"      # Example alias for editing Oh My Zsh
alias python="python3"                   # Default to Python 3
alias ta="tmux attach"                    # Attach to Tmux session
alias kube="kubectl -n solutions"         # Shorter Kubernetes command
alias lg="lazygit"                        # Open lazygit

# Configure PNPM (Package Manager for Node.js)
export PNPM_HOME="/home/rashmod/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;  # If already in PATH, do nothing
  *) export PATH="$PNPM_HOME:$PATH" ;;  # Otherwise, add it
esac

# Load Bun completions
[ -s "/home/rashmod/.bun/_bun" ] && source "/home/rashmod/.bun/_bun"

# Configure Bun (JavaScript runtime)
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
