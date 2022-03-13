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
  if ! command -v $1 &> /dev/null; then
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
  echo "~/.dotfiles is adding 'Visual Studio Code' ('code') to the \$PATH..."
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

echo "~/.dotfiles is refreshing the oh-my-zsh theme..."
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
      echo "~/.dotfiles is installing 'SDKMAN!'..."
      curl -s "https://get.sdkman.io" | bash
    fi

    echo "~/.dotfiles is adding 'SDKMAN!' ('sdk') to the \$PATH..."
    [[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"
  fi
}

setup_sdkman

#-------------------------------------------------------------------------------
#  brew (Homebrew) installation
#-------------------------------------------------------------------------------

if ! is_installed brew; then
  echo "~/.dotfiles is installing 'brew'..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> $HOME/.zprofile
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

#-------------------------------------------------------------------------------
#  pyenv installation
#-------------------------------------------------------------------------------

if ! is_installed pyenv; then
  echo "~/.dotfiles is installing 'pyenv'..."
  brew install pyenv
fi

#-------------------------------------------------------------------------------
#  Add pyenv to PATH
#-------------------------------------------------------------------------------

if [[ ":$PATH:" == *"pyenv"* ]]; then
  # do nothing, pyenv is already on the PATH
else
  echo "~/.dotfiles is adding 'pyenv' to the \$PATH..."
  eval "$(pyenv init --path)"
fi

#-------------------------------------------------------------------------------
#  node installation
#-------------------------------------------------------------------------------

if ! is_installed node; then
  echo "~/.dotfiles is installing 'node'..."
  brew install node
fi

if ! is_installed tsc; then
  echo "~/.dotfiles is installing TypeScript ('tsc') globally..."
  npm install --global typescript
fi

# used for checking if npm package names are available
if ! is_installed tsc; then
  echo "~/.dotfiles is installing npm-name-cli ('npm-name') globally..."
  npm install --global npm-name-cli
fi

#-------------------------------------------------------------------------------
#  zsh shell function to create a new TypeScript npm project
#-------------------------------------------------------------------------------

function mkts() {

  # parse command-line options
  # see: https://linux.die.net/man/1/zshmodules
  zparseopts -E -D y=yes -yes=yes h=help -help=help q=quiet -quiet=quiet

  # need help? incorrect usage?
  if [[ -n $help ]] || [[ -z $@ ]]; then
    echo "Usage: mkts <package-name>"
    return 1
  fi

  # some commands take a --quiet option, some take a --silent one
  if [[ -n $quiet ]]; then
    local silent="--silent"
  else
    local silent=""
  fi

  # use npm-name-cli to check if an npm package with this name already exists
  if [[ -z $yes ]] && ! npm-name $1; then
    echo -n "  continue anyway (y/n)? "; read answer
    case ${answer:0:1} in
      y|Y )
        ;; # continuing
      * )
        return 2 ;; # quitting
    esac
  fi

  # make a directory to hold this project
  if [[ -z $quiet ]]; then
    echo "\ncreating a new project at $1/"
  fi
  if ! mkdir $1; then
    return 1
  else
    cd $1
  fi

  # set up git
  git init $quiet &&
    echo "# $1" > README.md &&
    echo "/node_modules" > .gitignore &&
    git add .gitignore README.md &&
    git commit $quiet -m "init"

  # basic npm project setup
  if [[ -n $quiet ]]; then
    npm init -y &> '/dev/null'
  else
    npm init -y
  fi

  # add TypeScript support
  # see: https://khalilstemmler.com/blogs/typescript/node-starter-project/
  npm install $silent typescript @types/node --save-dev

  if [[ -n $quiet ]]; then
    npx tsc --init \
      --rootDir src --outDir build --esModuleInterop --resolveJsonModule \
      --lib es6 --module commonjs --allowJs true --noImplicitAny true &> '/dev/null'
  else
    npx tsc --init \
      --rootDir src --outDir build --esModuleInterop --resolveJsonModule \
      --lib es6 --module commonjs --allowJs true --noImplicitAny true
  fi

  # add some TypeScript files
  # see: https://blog.devgenius.io/create-your-own-npm-package-776c0a4873f4
  # see: https://itnext.io/step-by-step-building-and-publishing-an-npm-typescript-package-44fe7164964c
  mkdir src && \
    echo "export const Greeter = (name: string) => \`Hello, \${name}!\`;" > src/greeter.ts && \
    echo "export { Greeter } from './greeter'" > src/index.ts

  # define development scripts
  if ! grep -q "    \"test\": \"echo \\\\\"Error: no test specified\\\\\" && exit 1\"" package.json; then
    echo "package.json is formatted in an unexpected way. Cannot continue."
    return 1
  else
    # see: https://stackoverflow.com/a/12696224/2925434
    sed -i '' 's@    "test": "echo \\"Error: no test specified\\" && exit 1"@<SCRIPTS>@g' package.json

    local scripts="\
    \"clean\": \"rm -rf build/\",\n\
    \"build\": \"tsc\""

    sed -i '' "s@<SCRIPTS>@$scripts@g" package.json
  fi

  # test build command
  if [[ -n $silent ]]; then
    npm run build $silent
  else
    npm run build
  fi

  git add . && git commit -m "save point"


  # TODO:
  # run the script in an HTML file
  # add tests / linting / prettier / live-server / nodemon
  # publish the package to npm




  # move back to parent directory
  cd ..
}