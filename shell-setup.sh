# Installation instructions:
# 
# 1. install oh-my-zsh
# 2. add the following line to THE TOP OF .zshrc
#        source ~/.dotfiles/shell.sh
# 3. ???
# 4. profit

#-------------------------------------------------------------------------------
#  aliases and env vars
#-------------------------------------------------------------------------------

# because I accidentally type this all the time
alias sdkman="sdk"

# for ease of reloading terminal settings
alias so="source $HOME/.zshrc"

#-------------------------------------------------------------------------------
#  is_installed() tests if a command is available or not
#
#  example usage:
#
#    $ is_installed ls verbose
#      ls is installed
#
#    $ is_installed elless verbose
#      elless is not installed
#
#    $ is_installed ls # returns 0, prints nothing
#-------------------------------------------------------------------------------

function is_installed() {
  if ! (( $+commands[$1] )); then # this line only works in zsh
    if [[ $2 == "verbose" ]]; then
      echo "$1 is not installed"
    fi
    return 1
  else
    if [[ $2 == "verbose" ]]; then
      echo "$1 is installed"
    fi
    return 0
  fi
}

#-------------------------------------------------------------------------------
#  git setup
#-------------------------------------------------------------------------------

# set default editor to nano
export EDITOR=nano

# set default branch name to master
git config --global init.defaultBranch master
git config --global user.name "Andrew William Watson"
git config --global user.email "aww@awwsmm.com"
git config --global core.pager cat

#-------------------------------------------------------------------------------
#  Add IntelliJ shortcut (ij) -- could definitely be simplified
#-------------------------------------------------------------------------------

# source: https://gist.github.com/agoncal/8cfabe8e3e261c068902a95443d22079

function ij {

  # check for where the latest version of IDEA is installed
  local IDEA=`ls -1d /Applications/IntelliJ\ * | tail -n1`
  local wd=`pwd`

  # were we given a directory?
  if [ $# -eq 0 ] || [ -d "$1" ]; then
  #  echo "checking for things in the working dir given"
    wd=`ls -1d "$1" | head -n1`
  fi

  # were we given a file?
  if [ -f "$1" ]; then
  #  echo "opening '$1'"
    open -a "$IDEA" "$1"
  else
      # let's check for stuff in our working directory.
      pushd $wd > /dev/null

      # does our working dir have an .idea directory?
      if [ -d ".idea" ]; then
  #      echo "opening via the .idea dir"
        open -a "$IDEA" .

  #    # is there an IDEA project file?
  #    elif [ -f *.ipr ]; then
  #      echo "opening via the project file"
  #      open -a "$IDEA" `ls -1d *.ipr | head -n1`

  #    # Is there a pom.xml?
  #    elif [ -f pom.xml ]; then
  #      echo "importing from pom"
  #      open -a "$IDEA" "pom.xml"

      # can't do anything smart; just open IDEA
      else
  #      echo 'cbf'
        open -a "$IDEA" "./"
      fi

      popd > /dev/null
  fi

}

#-------------------------------------------------------------------------------
#  Add Visual Studio Code (code) to PATH
#-------------------------------------------------------------------------------

if [[ ":$PATH:" == *"Visual Studio Code.app"* ]]; then
  # do nothing, Visual Studio Code is already on the PATH
else
  export PATH=$PATH:"/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
fi

#-------------------------------------------------------------------------------
#  Add custom oh-my-zsh theme
#-------------------------------------------------------------------------------

function setup_zsh_theme() {
  local this_script_abs_dir=$( cd -- "$( dirname -- "${(%):-%x}" )" &> /dev/null && pwd )
  cp $this_script_abs_dir/awwsmm.zsh-theme ~/.oh-my-zsh/themes/
  sed -iE 's/^ZSH_THEME=.*/ZSH_THEME=awwsmm/' ~/.zshrc
}

setup_zsh_theme

#-------------------------------------------------------------------------------
#  SDKMAN! for JVM language management -- see: https://sdkman.io/install
#-------------------------------------------------------------------------------

function setup_sdkman() {

  # try to get the SDKMAN! version
  local LOCAL_SDKMAN_VERSION=$(sdk version 2>/dev/null)

  # if we can't find the SDKMAN! version...
  if [ -z "${LOCAL_SDKMAN_VERSION// }" ]; then
    export SDKMAN_DIR="$HOME/.sdkman"

    # check if it's installed...
    if [ ! -d $SDKMAN_DIR ]; then
      echo "Installing SDKMAN!"
      curl -s "https://get.sdkman.io" | bash
    fi

    [[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"
  fi
}

setup_sdkman

#-------------------------------------------------------------------------------
#  brew (Homebrew) installation
#-------------------------------------------------------------------------------

if ! is_installed brew; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> $HOME/.zprofile
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

#-------------------------------------------------------------------------------
#  pyenv installation
#-------------------------------------------------------------------------------

if ! is_installed pyenv; then
  brew install pyenv
fi

#-------------------------------------------------------------------------------
#  Add pyenv to PATH
#-------------------------------------------------------------------------------

if [[ ":$PATH:" == *"pyenv"* ]]; then
  # do nothing, pyenv is already on the PATH
else
  eval "$(pyenv init --path)"
fi
