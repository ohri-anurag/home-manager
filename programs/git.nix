{ user }:
{
  enable = true;
  ignores = [
    "node_modules"
  ];
  signing = {
    format = "ssh";
    key = user.bellroy.publicKey;
    signByDefault = true;
  };
  settings = {
    gpg.ssh.allowedSignersFile = "${user.homeDirectory}/.config/git/allowedSigners";
    init = {
      defaultBranch = "main";
    };
    safe.directory = "/etc/nixos";
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
    pull = {
      rebase = false;
    };
    user = {
      email = user.bellroy.email;
      name = user.name;
    };
  };
}
