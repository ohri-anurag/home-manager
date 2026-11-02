{ user }:
{
  enable = true;
  shellAliases = {
    g = "lazygit";
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
    jd = "jj diff";
    jst = "jj st";
    jp = "jj git push";
    jc = "jj commit -m";
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
  '';
}
