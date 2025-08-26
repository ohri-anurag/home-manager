{ user }:
{
  enable = true;
  shellAliases = {
    g = "glow -p -w 0";
    ga = "git add";
    gap = "git add --patch";
    gb = "git branch";
    gc = "git commit -m";
    gca = "git commit --amend";
    gcb = "git checkout -b";
    gd = "git diff";
    gdt = "git difftool -y";
    gds = "git diff --staged";
    gmt = "git mergetool";
    gp = "git push";
    gpf = "git push --force-with-lease";
    gpl = "git pull";
    gplm = "git pull origin master";
    gplr = "git pull --recurse-submodules";
    gpu = "git push --set-upstream origin $(git symbolic-ref --short HEAD)";
    grc = "git rebase --continue";
    gri = "git rebase -i";
    grs = "git rebase --skip";
    gra = "git rebase --abort";
    gst = "git status";
    ll = "ls -al";
    v = "nvim";
    z = "zellij";
  };
  enableCompletion = true;
  bashrcExtra = ''
    replace() {
      rg -l -F $1 . | xargs sed -i s/$1/$2/g
    }

    TASKS_FILE=${user.homeDirectory}/.taskfile
    function task() {
      bask ${user.homeDirectory}/task.bask
    }

    function tasks() {
      jq -r '(input_line_number | tostring) + " | " + .description + " => " + (.due | strptime("%Y-%m-%dT%H:%M:%SZ") | strftime("%d %b %Y"))' $TASKS_FILE
    }

    function finish() {
      sed -i $TASKS_FILE -e $1d $TASKS_FILE
    }

    rootDir="${user.bellroy.rootDir}/haskell"

    build() {
      cd $rootDir
      echo "optimization: False
    program-options
      ghc-options: -Wall" >cabal.project.local

      { git ls-files --other --exclude-standard; git diff --name-only --diff-filter=d; } | grep .hs | xargs hlint -h .hlint.yaml && cabal --builddir=$rootDir/dist-newstyle build $1 && cabal --builddir=$rootDir/dist-newstyle test $1
    }

    cover() {
      cd $rootDir
      echo "optimization: False
    program-options
      ghc-options: -Wall
    package *
      coverage: True
      library-coverage: True

    package order-processing
      coverage: False
      library-coverage: False

    " >cabal.project.local

      cabal --builddir=$rootDir/dist-newstyle-cover build $1 && cabal --builddir=$rootDir/dist-newstyle-cover test $1
    }

    debug() {
      cd "$rootDir" || exit
      echo "optimization: False
    program-options
      ghc-options: -Wwarn -Wunused-top-binds -Werror=unused-top-binds" >cabal.project.local
      cd $(dirname $(ls $(awk '/^packages:$/,/^program-options$/ {print $1}' cabal.project | head -n -1 | tail -n +2 | awk '{print $1"/*.cabal"}') | fzf -f "$1" | head -n 1)) || exit
      if [[ $2 != "" ]]; then
        target="$1:$2"
      else
        target=$1
      fi
      ghcid -c "cabal --builddir=$rootDir/dist-newstyle-debug repl $target" -o ghcid.txt

    }

    repl() {
      cd "$rootDir" || exit
      echo "optimization: False
    program-options
      ghc-options: -Wwarn -Wunused-top-binds -Werror=unused-top-binds" >cabal.project.local
      cd $(dirname $(ls $(awk '/^packages:$/,/^program-options$/ {print $1}' cabal.project | head -n -1 | tail -n +2 | awk '{print $1"/*.cabal"}') | fzf -f "$1" | head -n 1)) || exit
      if [[ $2 != "" ]]; then
        target="$1:$2"
      else
        target=$1
      fi
      cabal --builddir=$rootDir/dist-newstyle-debug repl $target

    }

    buildToolsComplete() {
      local cur_word type_list

      # COMP_WORDS is an array of words in the current command line.
      # COMP_CWORD is the index of the current word (the one the cursor is
      # in). So COMP_WORDS[COMP_CWORD] is the current word
      cur_word="''${COMP_WORDS[COMP_CWORD]}"
      type_list=$(ls $(awk -v rootDir=$rootDir '/^packages:$/,/^program-options$/ {print rootDir"/"$1"/*.cabal"}' $rootDir/cabal.project | head -n -1 | tail -n +2) | awk -F"/" '{print $NF}' | awk -F"." '{print $1}')

      # COMPREPLY is the array of possible completions, generated with
      # the compgen builtin.
      COMPREPLY=($(compgen -W "$type_list" -- "$cur_word"))
      return 0
    }

    # Register buildToolsComplete to provide completion for the following commands
    complete -F buildToolsComplete build cover debug repl
  '';
}
