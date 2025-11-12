export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="candy"


plugins=(git
        ansible
	    podman
        golang
        iterm2
        kitchen
        knife
        bundler
        gem
        kubectl
        macos
        terraform
        tmux
        ubuntu
        profiles
        )

source $ZSH/oh-my-zsh.sh

# load subitems...
for file in ~/.{,aliases,prompt,functions,path,dockerfunctions,ssh-agent,exports}; do
	if [[ -r "$file" ]] && [[ -f "$file" ]]; then
		source "$file"
	fi
done
unset file

# loading custom extra variables from other dotfiles environments
for file in $(find ${HOME} -maxdepth 1 -name ".extra.*"); do
	if [[ -r "$file" ]] && [[ -f "$file" ]]; then
		source "$file"
	fi
done
unset file

if [ $(command -v direnv) ]; then
   eval "$(direnv hook zsh)"
fi

function chpwd_profiles() {
    local profile context
    local -i reexecute

    
    context=":chpwd:profiles:$PWD"
    zstyle -s "$context" profile profile || profile='default'
    zstyle -T "$context" re-execute && reexecute=1 || reexecute=0

    if (( ${+parameters[CHPWD_PROFILE]} == 0 )); then
        typeset -g CHPWD_PROFILE
        local CHPWD_PROFILES_INIT=1
        (( ${+functions[chpwd_profiles_init]} )) && chpwd_profiles_init
    elif [[ $profile != $CHPWD_PROFILE ]]; then
        (( ${+functions[chpwd_leave_profile_$CHPWD_PROFILE]} )) \
            && chpwd_leave_profile_${CHPWD_PROFILE}
    fi
    if (( reexecute )) || [[ $profile != $CHPWD_PROFILE ]]; then
        (( ${+functions[chpwd_profile_$profile]} )) && chpwd_profile_${profile}
    fi

    CHPWD_PROFILE="${profile}"
    return 0
}

# Add the chpwd_profiles() function to the list called by chpwd()!
chpwd_functions=( ${chpwd_functions} chpwd_profiles )

chpwd_profiles

zstyle ':chpwd:profiles:*' re-execute false

[[ -e "$HOME/.ssh/config" ]] && complete -o "default" \
	-o "nospace" \
	-W "$(grep "^Host" ~/.ssh/config | \
	grep -v "[?*]" | cut -d " " -f2 | \
	tr ' ' '\n')" scp sftp ssh

autoload -U +X bashcompinit && bashcompinit

export PATH="/opt/homebrew/opt/llvm/bin:$PATH"
export JAVA_HOME=/opt/homebrew/opt/openjdk@21/

# Added by Windsurf
export PATH="/Users/mbuchleitner/.codeium/windsurf/bin:$PATH"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/mbuchleitner/.lmstudio/bin"
# End of LM Studio CLI section

