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
      jq -r '(input_line_number | tostring) + " | " + (.due | strptime("%Y-%m-%dT%H:%M:%SZ") | strftime("%d %b %Y")) + " | " + .description' $TASKS_FILE
    }

    function finish() {
      sed -i -e $1d $TASKS_FILE
    }

    rootDir="${user.bellroy.rootDir}/haskell"

    build() {
      bask ${user.homeDirectory}/build.bask $1
    }

    cover() {
      bask ${user.homeDirectory}/cover.bask $1
    }

    debug() {
      bask ${user.homeDirectory}/debug.bask $1 $2
    }

    repl() {
      bask ${user.homeDirectory}/repl.bask $1 $2
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
