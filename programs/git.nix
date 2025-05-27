{
  difftastic = {
    enable = true;
  };
  enable = true;
  extraConfig = {
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
  };
  userEmail = "anurag.ohri@bellroy.com";
  userName = "Anurag Ohri";
}
