{
  enable = true;
  shellAliases = {
    g = "glow -p -w 0";
    ga = "git add";
    gap = "git add --patch";
    gb = "git branch";
    gc = "git commit -S -m";
    gca = "git commit -S --amend";
    gcb = "git checkout -b";
    gd = "git diff";
    gdt = "git difftool -y";
    gds = "git diff --staged";
    gmt = "git mergetool";
    gp = "git push";
    gpf = "git push --force-with-lease";
    gpl = "git pull";
    gplm = "git pull -S origin master";
    gplr = "git pull --recurse-submodules";
    gpu = "git push --set-upstream origin '$(git symbolic-ref --short HEAD)'";
    grc = "git rebase --continue";
    gri = "git rebase -i";
    grs = "git rebase --skip";
    gra = "git rebase --abort";
    gst = "git status";
    ll = "ls -al";
    v = "nvim";
  };
  enableCompletion = true;
  bashrcExtra = ''
    replace() {
      rg -l -F $1 . | xargs sed -i s/$1/$2/g
    }

    TASKS_FILE=~/tasks.json
    function task() {
      DESC=$(gum input --placeholder "What needs doing?")
      DUESTR=$(gum input --placeholder "When is it due?")
      DUE=$(date -u -d "$(date -d "$DUESTR")" +"%Y-%m-%dT%H:%M:%SZ")
      N=$(jq 'map(.id) | max' $TASKS_FILE)
      if [[ $N -eq 100 ]]
      then
        N=1
      else
        N=$((N + 1))
      fi
      TASK='{"id": '$N', "desc": "'$DESC'", "due": "'$DUE'"}'
      if [[ -z "$DESC" || -z "$DUE" ]]
      then
        echo "Need both description and due date"
        return
      fi
      jq '. += ['"$TASK"'] | sort_by(.due | fromdate)' $TASKS_FILE > ~/tasks.json.tmp
      mv ~/tasks.json.tmp $TASKS_FILE
    }

    function tasks() {
      N=$(jq 'length' $TASKS_FILE)
      if [[ $N -eq 0 ]]
      then
        echo "$(gum style --foreground 120 "You don't have any tasks left!! Hooray!!")"
        return
      fi
      HEADER_DATE=$(gum style --padding="0 4" --foreground 167 --border normal --border-foreground 167 "Date")
      HEADER_DESC=$(gum style --padding="0 15" --foreground 104 --border normal --border-foreground 104 "Description")
      HEADER_ID=$(gum style --padding="0 1" --foreground 115 --border normal --border-foreground 115 "ID")
      HEADER=$(gum join "$HEADER_DATE" "$HEADER_DESC" "$HEADER_ID")
      echo "$HEADER"
      jq '.[]' -c $TASKS_FILE | while read task; do
        DATE=$(date +"%d %b %Y" -d "$(echo $task | jq -r '.due')" | gum style --padding="0 1" --foreground 167 --border none --border-foreground 167)
        DESC=$(echo $task | jq -r '.desc' | gum style --width 41 --foreground 104 --margin="0 0 0 2")
        ID=$(echo $task | jq -r '.id' | gum style --width 5 --margin="0 0 0 2" --foreground 115)
        echo "$(gum join "$DATE" "$DESC" "$ID")"
      done
    }

    function finished() {
      if [[ -z "$1" ]]
      then
        echo "Need an ID to mark a task as finished"
        return
      fi
      jq 'map(select(.id != '$1'))' $TASKS_FILE > ~/tasks.json.tmp
      mv ~/tasks.json.tmp $TASKS_FILE
    }

    function notify() {
      ~/notify.sh
    }

    function start() {
      PROJECT=$(gum choose --header="Select Project:" "Break" "Implementation" "Investigation" "Learning" "Meeting" "Pairing")
      DESC=$(gum input --placeholder "Describe the task you want to log time for:")
      case $PROJECT in
        "Break")
          PROJECT_ID=209847916
          COLOR=134
          ;;
        "Implementation")
          PROJECT_ID=209534029
          COLOR=61
          ;;
        "Investigation")
          PROJECT_ID=209534030
          COLOR=32
          ;;
        "Learning")
          PROJECT_ID=209534031
          COLOR=172
          ;;
        "Meeting")
          PROJECT_ID=209538618
          COLOR=160
          ;;
        "Pairing")
          PROJECT_ID=209561028
          COLOR=34
          ;;
        *)
          echo "Need a valid project name"
          return
          ;;
      esac
      https --print b -a 4e5a3390c7dcf8a52dfaf0c6cf02a2b8:api_token POST \
        api.track.toggl.com/api/v9/workspaces/9258696/time_entries \
        description="$DESC" \
        start=$(date -u +"%Y-%m-%dT%H:%M:%SZ") \
        workspace_id:=9258696 \
        created_with="Anurag's bash script using HTTPie" \
        duration:=-1 \
        project_id:=$PROJECT_ID | jq '.id' > ~/toggl_id
      if [[ $? -eq 0 ]]
      then
        echo "$(gum style \
          --foreground "$COLOR" \
          --border normal \
          --border-foreground "$COLOR" \
          "$DESC" )"
        return
      fi
    }

    function stop() {
      TASK_ID=$(cat ~/toggl_id)
      https -q -a 4e5a3390c7dcf8a52dfaf0c6cf02a2b8:api_token PATCH \
        api.track.toggl.com/api/v9/workspaces/9258696/time_entries/"$TASK_ID"/stop
    }

    rootDir="/home/anuragohri92/bellroy/haskell"

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

    export OPENAI_API_KEY="$(cat ~/.openaikey)"
  '';
}
