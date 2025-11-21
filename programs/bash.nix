{ user }:
{
  enable = true;
  shellAliases = {
    ga = "git add";
    gap = "git add --patch";
    gb = "git branch";
    gc = "git commit -m";
    gca = "git commit --amend";
    gcb = "git checkout -b";
    gd = "GIT_EXTERNAL_DIFF=difft git diff";
    gdt = "git difftool -y";
    gds = "GIT_EXTERNAL_DIFF=difft git diff --staged";
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
    m = "glow -p -w 0 -s dracula";
    v = "nvim";
    z = "zellij";
  };
  enableCompletion = true;
  bashrcExtra = ''
    replace() {
      rg -l -F $1 . | xargs sed -i s/$1/$2/g
    }

    garbage() {
      home-manager expire-generations today
      cd ${user.homeDirectory}/bellroy
      ls -A | xargs -I {} sh -c 'rm -rf "{}"/.direnv && rm -rf "{}"/node_modules'
      rm -rf haskell/dist-*
      nix store gc -vvvvvv
    }

    TASKS_FILE=${user.homeDirectory}/.taskfile
    function task() {
      read -p "What needs doing? " desc
      read -p "When is it due? " due

      duedate=$(date -u +%Y-%m-%dT%H:%M:%SZ -d "$due" | tr -d '\n')

      echo "{ \"due\": \"$duedate\", \"description\": \"$desc\" }" >> ${user.homeDirectory}/.taskfile
      sort -o ${user.homeDirectory}/.taskfile ${user.homeDirectory}/.taskfile
    }

    function tasks() {
      jq -r '(input_line_number | tostring) + " | " + (.due | strptime("%Y-%m-%dT%H:%M:%SZ") | strftime("%d %b %Y")) + " | " + .description' $TASKS_FILE
    }

    function finish() {
      sed -i -e $1d $TASKS_FILE
    }

    rootDir="${user.bellroy.rootDir}/haskell"

    h() {
      url=$(hoogle $1 --json \
      | jq -rc '.[] | "[" + .module.name + "] " + .item + "|" + .url + "|" + .docs | sub("\\n";"<br>";"g")' \
      | fzf \
        -d '|' \
        --with-nth='{1}' \
        --accept-nth=2 \
        --header="Hoogle: $1" \
        --preview="echo {1} | sed 's/ /\n\n/' | sed 's/->/\n\t->/g'; echo; echo {3..} | lynx --dump --stdin" \
        --preview-label='Docs' \
        --cycle \
        --bind 'ctrl-d:preview-down,ctrl-u:preview-up')
      if [[  -n $url  ]]; then
        firefox $url
      fi
    }
    build() {
      cd ${user.homeDirectory}/bellroy/haskell/
      echo -e "optimization: False\nprogram-options\n  ghc-options: -Wall" > cabal.project.local |
        { git ls-files --other --exclude-standard -- *.hs; git diff --name-only --diff-filter=d -- '*.hs'; } |
        xargs hlint -h .hlint.yaml |
        cabal --builddir=dist-newstyle build $1 && cabal --builddir=dist-newstyle test $1
    }

    cover() {
      cd ${user.homeDirectory}/bellroy/haskell/
      echo -e "optimization: False\nprogram-options\n  ghc-options: -Wall\npackage *\n  coverage: True\n  library-coverage: True\n\npackage order-processing\n  coverage: False\n  library-coverage: False" > cabal.project.local |
        { git ls-files --other --exclude-standard -- *.hs; git diff --name-only --diff-filter=d -- '*.hs'; } |
        xargs hlint -h .hlint.yaml |
        cabal --builddir=dist-newstyle-cover build $1 && cabal --builddir=dist-newstyle-cover test $1
    }

    debug() {
      cabalPath=$(cd ${user.homeDirectory}/bellroy/haskell/ |
        echo -e "optimization: False\nprogram-options\n  ghc-options: -Wwarn -Wunused-top-binds -Werror=unused-top-binds" > cabal.project.local |
        fd .*.cabal\$ . |
        fzf -f "$1" |
        head -n 1)

      cd $(dirname $cabalPath)
      pwd

      if [[ $2 != "" ]]; then
        target=$1:$2
      else
        target=$1
      fi
      ghcid -c "cabal --builddir=${user.homeDirectory}/bellroy/haskell/dist-newstyle-debug repl $target" -o ghcid.txt
    }

    repl() {
      cabalPath=$(cd ${user.homeDirectory}/bellroy/haskell/ |
        echo -e "optimization: False\nprogram-options\n  ghc-options: -Wwarn -Wunused-top-binds -Werror=unused-top-binds" > cabal.project.local |
        fd .*.cabal\$ . |
        fzf -f "$1" |
        head -n 1)

      cd $(dirname $cabalPath)
      pwd

      if [[ $2 != "" ]]; then
        target=$1:$2
      else
        target=$1
      fi
      cabal --builddir=${user.homeDirectory}/bellroy/haskell/dist-newstyle-debug repl $target
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
