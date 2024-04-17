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

# set default pager to cat
export PAGER=cat

# set default branch name to master
git config --global init.defaultBranch master
git config --global user.name "Andrew William Watson"
git config --global user.email "aww@awwsmm.com"
git config --global core.pager cat

# set default merge conflict resolution strategy
git config --global pull.rebase false

# if we try to push to a branch that doesn't exist remotely, create it
git config --global push.autoSetupRemote true

#-------------------------------------------------------------------------------
#  Add IntelliJ shortcut (ij)
#-------------------------------------------------------------------------------

# source: https://gist.github.com/agoncal/8cfabe8e3e261c068902a95443d22079

function ij {

  # check for where the latest version of IDEA is installed
  local IDEA=`ls -1d /Applications/IntelliJ\ * | tail -n1`
  local wd=`pwd`

  # were we given a directory?
  if [ $# -eq 0 ] || [ -d "$1" ]; then
    wd=`ls -1d "$1" | head -n1`
  fi

  # were we given a file?
  if [ -f "$1" ]; then
    open -a "$IDEA" "$1"
  else
      # let's check for stuff in our working directory.
      pushd $wd > /dev/null

      # does our working dir have an .idea directory?
      if [ -d ".idea" ]; then
        open -a "$IDEA" .

      # can't do anything smart; just open IDEA
      else
        open -a "$IDEA" "./"
      fi

      popd > /dev/null
  fi

}

#-------------------------------------------------------------------------------
#  Add RustRover shortcut (rr)
#-------------------------------------------------------------------------------

function rr {

  # check for where the latest version of RustRover is installed
  local ROVER=`ls -1d /Applications/RustRover\ * | tail -n1`
  local wd=`pwd`

  # were we given a directory?
  if [ $# -eq 0 ] || [ -d "$1" ]; then
    wd=`ls -1d "$1" | head -n1`
  fi

  # were we given a file?
  if [ -f "$1" ]; then
    open -a "$ROVER" "$1"
  else
      # let's check for stuff in our working directory.
      pushd $wd > /dev/null

      # does our working dir have an .idea directory?
      if [ -d ".idea" ]; then
        open -a "$ROVER" .

      # can't do anything smart; just open ROVER
      else
        open -a "$ROVER" "./"
      fi

      popd > /dev/null
  fi

}

#-------------------------------------------------------------------------------
#  Add Coursier (cs) to PATH
#-------------------------------------------------------------------------------

if [[ ":$PATH:" == *"Coursier"* ]]; then
  # do nothing, Coursier is already on the PATH
else
  echo "~/.dotfiles is adding 'Coursier' ('cs') to the \$PATH..."
  export PATH=$PATH:"/Users/andrew/Library/Application Support/Coursier/bin"
fi

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
#  code (Visual Studio Code) installation
#-------------------------------------------------------------------------------

if ! is_installed code; then
  echo "~/.dotfiles is installing Visual Studio Code..."
  brew install --cask visual-studio-code
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

#-------------------------------------------------------------------------------
#  zsh shell function to create a new TypeScript npm project
#-------------------------------------------------------------------------------

function mkts() {

  # add flags to
  #  - publish to npm?
  #  - create a local "sandbox" HTML file using webpack?
  #  - configure hot reloading with nodemon / webpack-dev-server?

  # parse command-line options
  # see: https://linux.die.net/man/1/zshmodules
  zparseopts -E -D p=publish -publish=publish h=help -help=help q=quiet -quiet=quiet

  # need help? incorrect usage?
  if [[ -n $help ]] || [[ -z $@ ]]; then
    echo "Usage: mkts [--help] [--publish] [--quiet] <package-name>"
    echo "         -h, --help       display this help menu"
    echo "         -p, --publish    publish this project to npm"
    echo "         -q, --quiet      suppress all output"
    return 1
  fi

  # some commands take a --quiet option, some take a --silent one
  if [[ -n $quiet ]]; then
    local silent="--silent"
  else
    local silent=""
  fi

  # use npm-name-cli to check if an npm package with this name already exists
  npm install $silent --global npm-name-cli
  if [[ -n $publish ]] && ! npm-name $1; then
    echo "ERROR: project with name $1 already exists on npm. Try a different name."
    return 2
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
      --rootDir src --outDir build --esModuleInterop --resolveJsonModule --sourceMap \
      --lib es6,dom --module commonjs --noImplicitAny true &> '/dev/null'
  else
    npx tsc --init \
      --rootDir src --outDir build --esModuleInterop --resolveJsonModule --sourceMap \
      --lib es6,dom --module commonjs --noImplicitAny true
  fi

  # add some example TypeScript files
  # see: https://blog.devgenius.io/create-your-own-npm-package-776c0a4873f4
  # see: https://itnext.io/step-by-step-building-and-publishing-an-npm-typescript-package-44fe7164964c
  mkdir src && \
    echo "export * from './greeter'" > src/index.ts && \
    echo "$(sed -e 's/[ ]*\| //g' -e '1d;$d' <<'--------------------'
      | 
      | export default class Greeter {
      |   greet(name: string) { return `Hello, ${name}!`; }
      | }
      | 
--------------------
      )" > src/greeter.ts

  # helper function to add one or more scripts to package.json
  function add_scripts() {
    local anchor="  \"scripts\": {"

    # abort if given an odd number of arguments (or none at all)
    if [ $# -eq 0 ] || [ $(($#%2)) -eq 1 ]; then
      echo "add_scripts expects a positive, even number of arguments"
      return 1
    fi

    # find the "scripts" line in package.json
    if ! grep -q $anchor package.json; then
      echo "package.json is formatted in an unexpected way. Cannot continue."
      return 1
    else
      local scripts=""

      # loop through the arguments, two at a time, adding a new script on each line
      while [ ! -z "$1" ]; do
        scripts=$scripts"\n    \"$1\": \"$2\","
        shift 2
      done

      # see: https://stackoverflow.com/a/12696224/2925434
      sed -i '' "s@$anchor@$anchor$scripts@g" package.json
    fi
  }

  # define development scripts
  add_scripts "clean" "rm -rf build" "build" "tsc"

  # test build command
  if [[ -n $silent ]]; then
    npm run build $silent
  else
    npm run build
  fi

  # save here
  git add . && git commit $quiet -m "skeleton TypeScript configuration"

  #---------------------------------------------------------
  #  optional: use webpack to bundle TypeScript code as JavaScript to run in the browser
  #---------------------------------------------------------

  # see: https://bit.ly/3KJ4ntV
  npm install $silent --save-dev webpack webpack-cli ts-loader

  # the sandbox directory will hold a simple example
  mkdir sandbox

  # allow both the src/ and sandbox/ directories to contain .ts files
  sed -E -i '' 's/    \"rootDir\": \"src\",.*/    \"rootDirs\": \[ \"src\", \"sandbox\" \],/g' tsconfig.json

  # create a simple HTML file for the sandbox example
  echo "$(sed -e 's/[ ]*\| //g' -e '1d;$d' <<'--------------------'
    | 
    | <!DOCTYPE html>
    | <html>
    |   <head>
    |     <script src='index.js'></script>
    |   </head>
    |   <body>
    |     <span id='hello-world'></span>
    |   </body>
    | </html>
    | 
--------------------
    )" > sandbox/index.html

  # and create a simple TypeScript file
  echo "$(sed -e 's/[ ]*\| //g' -e '1d;$d' <<'--------------------'
    | 
    | import Greeter from "../src/greeter";
    | 
    | function helloWorld() {
    |   const element = document.getElementById('hello-world');
    |   
    |   if (element) {
    |     const greeter = new Greeter();
    |     element.textContent = greeter.greet('World');
    |   }
    | }
    | 
    | window.onload = (ev: Event) => helloWorld();
    | 
--------------------
    )" > sandbox/index.ts

  # and configure webpack
  echo "$(sed -e 's/[ ]*\| //g' -e '1d;$d' <<'--------------------'
    | 
    | const path = require('path');
    | 
    | module.exports = {
    |   mode: 'none',
    |   entry: './sandbox/index.ts',
    |   devtool: 'inline-source-map',
    |   module: {
    |     rules: [
    |       {
    |         test: /\.tsx?$/,
    |         use: 'ts-loader',
    |         exclude: /node_modules/,
    |       },
    |     ],
    |   },
    |   resolve: {
    |     extensions: ['.tsx', '.ts', '.js'],
    |   },
    |   output: {
    |     filename: 'index.js',
    |     path: path.resolve(__dirname, 'sandbox'),
    |   },
    | };
    | 
--------------------
    )" > webpack.config.js

  # add 'sandbox' script to package.json
  add_scripts "sandbox" "npx webpack"

  # save here
  git add . && git commit $quiet -m "webpack and sandbox"

  #---------------------------------------------------------
  #  optional: add hot reloading via nodemon / webpack-dev-server
  #---------------------------------------------------------

  # https://khalilstemmler.com/blogs/typescript/node-starter-project/
  npm install $silent --save-dev ts-node nodemon

  # hot reload src/
  echo "$(sed -e 's/[ ]*\| //g' -e '1d;$d' <<'--------------------'
    | 
    | {
    |   "watch": ["src"],
    |   "ext": ".ts,.js",
    |   "ignore": [],
    |   "exec": "ts-node ./src/index.ts"
    | }
    | 
--------------------
    )" > nodemon.json

  # https://javascript.plainenglish.io/typescript-environment-with-webpack-compilation-and-automatic-reload-b4d6d5a60f6f
  npm install $silent --save-dev webpack-dev-server

  # hot reload sandbox/
  local devServer="\n  devServer: {\n    static: './sandbox',\n    hot: true\n  },"
  sed -i '' "s@module.exports = {@module.exports = {$devServer@g" webpack.config.js

  # add nodemon scripts to package.json
  add_scripts "dev" "nodemon" "dev-sandbox" "webpack serve"

  # save here
  git add . && git commit $quiet -m "hot reloading"

  # TODO:
  # - add optional step to publish to npm
  # - add optional step to add dummy tests
  # - add optional step to add linting / prettier

  # print out instructions based on flags passed in
  # something like
  # -----
  # View your new project with
  #   cd <dir-name> && ls
  #
  # Then, try some scripts (defined in package.json)
  #
  #   npm run build # build the project
  #   npm run sandbox # check out the sandbox HTML file
  #   npm run publish # ... etc.
  # -----

  # move back to parent directory
  cd ..
}

#---------------------------------------------------------
#  set up git Hosts in ~/.ssh
#---------------------------------------------------------

# https://gist.github.com/rahularity/86da20fe3858e6b311de068201d279e3

touch ~/.ssh/config

if ! grep -q "Host ngtt-gitlab" ~/.ssh/config; then

  cp ~/.ssh/config ~/.ssh/config.bak

  echo "$(sed -e 's/[ ]*\| //g' -e '1d;$d' <<'--------------------'
    | 
    | # git clone git@ngtt-gitlab:path/to/repo.git
    | Host ngtt-gitlab
    |   HostName gitlab.com
    |   User git
    |   IdentityFile ~/.ssh/ngtt-gitlab
    | 
    | # git clone git@ngtt-github:path/to/repo.git
    | Host ngtt-github
    |   HostName github.com
    |   User git
    |   IdentityFile ~/.ssh/ngtt-github
    | 
    | # git clone git@github.com:path/to/repo.git
    | Host github.com
    |   HostName github.com
    |   User git
    |   IdentityFile ~/.ssh/personal-github
    | 
--------------------
    )" >> ~/.ssh/config
fi
