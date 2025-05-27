{
  enable = true;
  shellAliases = {
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

    # If there is .bashenv.sh file in the directory where the terminal is started, this will load it.
    if [ -f .bashenv.sh ]; then
      source .bashenv.sh
    fi
    function cd() {
      # If there is .bashenv.sh file in the directory being `cd`ed, this will load it.
      builtin cd "$@" || return
      if [ -f .bashenv.sh ]; then
        source .bashenv.sh
      fi
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

    export OPENAI_API_KEY="$(cat ~/.openaikey)"
  '';
}
