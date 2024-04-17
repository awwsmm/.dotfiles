# See: https://blog.carbonfive.com/writing-zsh-themes-a-quickref/

ZSH_THEME_GIT_PROMPT_PREFIX="on "
ZSH_THEME_GIT_PROMPT_SUFFIX=""
ZSH_THEME_GIT_PROMPT_DIRTY="*"
ZSH_THEME_GIT_PROMPT_CLEAN=""

setopt inc_append_history_time

TIME_FORMAT="%a %b %e | %k:%M:%S"

function last_command_end() {
  # strip :START: and everything before, and :END: and everything after, to get the timestamp of the previous command
  local LAST_CMD=$(history -t ":START:$TIME_FORMAT:END:" -1 | sed -E 's/.*:START://g' | sed -E 's/:END:.*//g')
  echo $LAST_CMD
}

PROMPT=$'\n# %F{red}$(last_command_end)%f\n# %B%F{green}%D{$TIME_FORMAT}%f in %F{cyan}$(print $PWD)%f\n#                       %F{yellow}$(git_prompt_info)%f\n\$%b '

TMOUT=1

TRAPALRM() {
    zle reset-prompt
}