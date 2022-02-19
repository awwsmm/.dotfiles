# See: https://blog.carbonfive.com/writing-zsh-themes-a-quickref/

ZSH_THEME_GIT_PROMPT_PREFIX="on "
ZSH_THEME_GIT_PROMPT_SUFFIX=""
ZSH_THEME_GIT_PROMPT_DIRTY="*"
ZSH_THEME_GIT_PROMPT_CLEAN="✨"

PROMPT=$'\n%B%F{cyan}[ %D{%a %b %e | %k:%M:%S} ] %F{blue}%n%f @ %F{magenta}%m%f : %F{green}$(print -rD $PWD)\n                          %F{yellow}$(git_prompt_info)%f\n\$%b '