# See: https://blog.carbonfive.com/writing-zsh-themes-a-quickref/

ZSH_THEME_GIT_PROMPT_PREFIX="on "
ZSH_THEME_GIT_PROMPT_SUFFIX=""
ZSH_THEME_GIT_PROMPT_DIRTY="*"
ZSH_THEME_GIT_PROMPT_CLEAN=""

setopt inc_append_history_time

TIME_FORMAT="%a %b %e | %k:%M:%S"

function last_command_end() {
  local LAST_CMD=$(history -t "[ $TIME_FORMAT ]" | tail -1 | sed -E 's/^[^\[]*//g' | sed -E 's/\].*/\]/g')
  echo $LAST_CMD
}


PROMPT=$'\n%F{red}$(last_command_end)\n%B%F{green}[ %D{$TIME_FORMAT} ] %F{blue}%n%f@%F{magenta}%m%f:%F{cyan}$(print -rD $PWD)\n                          %F{yellow}$(git_prompt_info)%f\n\$%b '

TMOUT=1

TRAPALRM() {
    zle reset-prompt
}