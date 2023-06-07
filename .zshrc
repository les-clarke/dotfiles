source ~/.zsh_aliases
# infra repo setup
export INFRASTRUCTURE_DEPLOYMENT_REPO_PATH="$HOME/Klaviyo/Repos/infrastructure-deployment"
source $INFRASTRUCTURE_DEPLOYMENT_REPO_PATH/bashenv/source.sh

source "$HOME/.cargo/env"
export DOTNET_ROOT="/usr/local/share/dotnet"
export PATH="/Users/les.clarke/.klaviyocli/.bin:$PATH"
export PATH="/Users/les.clarke/bin:$PATH"
export PATH="$DOTNET_ROOT:$PATH"


autoload -Uz compinit
compinit

#Mono repo shell config https://github.com/klaviyo/app/blob/master/docs/shell_config.md
source ~/Klaviyo/Repos/app/config/app/osx_dev_profile.bash
export KL_SSH_USERNAME=lesclarke
export KL_GIT_INITIALS=LC
export GITHUB_USERNAME="les-clarke"
eval "$(_KLAVIYOCLI_COMPLETE=zsh_source klaviyocli)"

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"
unsetopt inc_append_history
unsetopt share_history

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="kolo"


# Uncomment the following line to enable command auto-correction.
#disable auto correct
ENABLE_CORRECTION="false"
unsetopt correct_all
unsetopt correct

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"


# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git)

source $ZSH/oh-my-zsh.sh

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# place this after nvm initialization!
autoload -U add-zsh-hook
load-nvmrc() {
  local node_version="$(nvm version)"
  local nvmrc_path="$(nvm_find_nvmrc)"

  if [ -n "$nvmrc_path" ]; then
    local nvmrc_node_version=$(nvm version "$(cat "${nvmrc_path}")")

    if [ "$nvmrc_node_version" != "$node_version" ]; then
      nvm use
    fi
  fi
}
add-zsh-hook chpwd load-nvmrc
load-nvmrc

#https://klaviyo.atlassian.net/wiki/spaces/EN/pages/3573252187/Helpful+Bash+Zsh+Scripts
#Use this when you update a component and now have a bunch of failing snapshot tests from other packages in CI.
snap() {
  echo $1 | tr -d '\n' | sed -e 's/* \// /g' | xargs yarn test -u
}

# Use this when you rebase and have a bunch of merge conflicts in snapshot files
snapBack() {
  gs | grep '\.snap' | tr -d '\n' | sed -e 's/\s*both modified:\s*//g' -e 's/\s*modified:\s*//g' -e 's/__snapshots__\///g' -e 's/.snap//g' | xargs yarn test -u
}