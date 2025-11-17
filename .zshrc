zmodload zsh/zprof
PROFILE_STARTUP=false
if [[ "$PROFILE_STARTUP" == true ]]; then
    # http://zsh.sourceforge.net/Doc/Release/Prompt-Expansion.html
    PS4=$'%D{%M:%S.%6.}(%x:%I): '
    exec 3>&2 2> >(awk '{ if ($1 ~ /^[0-9][0-9]:[0-9][0-9].[0-9]+/ && $1 > 0.1) print }' > /tmp/startlog.$$)
    setopt xtrace prompt_subst
fi
autoload -Uz compinit

# Initialize compinit once
if [[ -z "$ZSH_COMPDUMP" ]]; then
  export ZSH_COMPDUMP="${ZDOTDIR:-$HOME}/.zcompdump"
fi
# Only run compinit once per day
if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi
eval "$(/opt/homebrew/bin/brew shellenv)"
export ZSH="$HOME/.oh-my-zsh"
export GOPATH="$HOME/go"
path=(
    "$HOME/scripts"
    "$HOME/.klaviyocli/.bin"
    "$GOPATH/bin"
    "$HOME/protoc-25.4-osx-aarch_64/bin"
    "/Users/les.clarke/.cargo/bin"
    $path
)
export PATH
ZSH_THEME="robbyrussell"
#nvm stuff
export NVM_LAZY_LOAD=true;
export NVM_COMPLETION=true;
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
plugins=(
  "git"
  "direnv"
)
source $ZSH/oh-my-zsh.sh
unsetopt inc_append_history
unsetopt share_history

#disable auto correct
ENABLE_CORRECTION="false"
unsetopt correct_all
unsetopt correct

# User configuration
export GPG_TTY=$(tty)
eval "$(pyenv init --path)"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"
ulimit -Sn 10240
source /Users/les.clarke/.s2a_login
source /Users/les.clarke/.apprc
export CURRENT_UID="$(id -u):$(id -g)"
export MAINLINE_PYTHON=/Users/les.clarke/.pyenv/versions/app/bin/python
export PATH="$HOME/.klaviyocli/.bin:$PATH"
# Lazy load klaviyocli completion
klaviyo_completion_init() {
    unfunction klaviyo_completion_init
}
compdef klaviyo_completion_init klaviyocli
export KL_SSH_USERNAME=lesclarke
export KL_GIT_INITIALS=LC

export CHARIOT_SETTINGS=module:klaviyo_schema.kms.config.settings_development
export GOPRIVATE=github.com/klaviyo
# Set personal aliases, overriding those provided by oh-my-zsh libs,
source ~/.zsh_aliases
[ -f ~/.zsh_secrets ] && source ~/.zsh_secrets

autoload -U add-zsh-hook


[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
if [[ "$PROFILE_STARTUP" == true ]]; then
    unsetopt xtrace
    exec 2>&3 3>&-
    # Show results
    echo "Startup log saved to /tmp/startlog.$$"
fi
export CHARIOT_SETTINGS=/Users/les.clarke/Klaviyo/Repos/k-repo/python/klaviyo/kms/config/settings/settings_development.py
export KCLI_AUTO_UPDATE=true
export AWS_REGION=us-east-1  # or your preferred region
export SAML2AWS_SESSION_DURATION=28800
source ~/.klaviyocli/.zshcompletions/_klaviyocli || true
export PATH="$HOME/.local/bin:$PATH"
export KL_LOCAL_MYSQL_ROOT_PASSWORD=nYOYtP7OOHaeDnBaOmRb
export KL_AWS_CUSTOM_S3_ENDPOINT=http://localhost:9000
export KL_LOCAL_DYNAMODB_ENDPOINT=http://localhost:4566
export KL_LOCAL_KMS_ENDPOINT=http://localhost:4566

find-pod() {
      if [ -z "$1" ] || [ -z "$2" ]; then
          echo "Usage: find-pod <namespace> <pod-name>"
          return 1
      fi

      local namespace="$1"
      local pod_name="$2"
      local original_context=$(kubectl config current-context)

      echo "Searching for pod '$pod_name' in namespace '$namespace'..."

      # Read contexts line by line
      kubectl config get-contexts -o name | grep "prod-edam" | while read -r context; do
          echo "Checking context: $context"
          kubectl config use-context "$context" &>/dev/null

          # Capture kubectl output to check for specific errors
          local result=$(kubectl get pod "$pod_name" -n "$namespace" 2>&1)

          if echo "$result" | grep -q "Unauthorized"; then
              echo "⚠ Unauthorized - you need to log in to this cluster"
              echo "Try s2a-login"
              return -1
          fi

          if echo "$result" | grep -qv "NotFound" && echo "$result" | grep -qv "Error"; then
              echo "✓ Found pod in context: $context"
              return 0
          fi
      done

      echo "✗ Pod not found in any context"
      kubectl config use-context "$original_context" &>/dev/null
      echo "Switched back to original context: $original_context"
      return 1
  }
