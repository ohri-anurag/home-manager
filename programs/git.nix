{ user }:
{
  difftastic = {
    enable = true;
  };
  enable = true;
  extraConfig = {
    gpg.ssh.allowedSignersFile = "${user.homeDirectory}/.config/git/allowedSigners";
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
    key = user.bellroy.publicKey;
    signByDefault = true;
  };
  userEmail = user.bellroy.email;
  userName = user.name;
}
