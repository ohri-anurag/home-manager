{
  difftastic = {
    enable = true;
  };
  enable = true;
  extraConfig = {
    gpg.ssh.allowedSignersFile = "~/.config/git/allowedSigners";
    init = {
      defaultBranch = "main";
    };
    diff = {
      tool = "nvimdiff";
    };
    merge = {
      conflictStyle = "diff3";
      tool = "nvimdiff";
    };
    mergetool = {
      keepBackup = false;
    };
  };
  ignores = [
    "node_modules"
  ];
  signing = {
    format = "ssh";
    key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB4L1Uado9BQOqZVhSebRRxGojB1gde2cnrMAlrUBDzB anurag.ohri@bellroy.com";
    signByDefault = true;
  };
  userEmail = "anurag.ohri@bellroy.com";
  userName = "Anurag Ohri";
}
