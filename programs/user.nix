rec {
  name = "Anurag Ohri";
  username = "anuragohri92";
  homeDirectory = "/home/${username}";
  bellroy = rec {
    rootDir = "${homeDirectory}/bellroy";
    ssh = {
      user = "anurag";
      privateKeyPath = "${homeDirectory}/.ssh/id_ed25519";
    };
    email = "anurag.ohri@bellroy.com";
    publicKeyWithoutEmail = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB4L1Uado9BQOqZVhSebRRxGojB1gde2cnrMAlrUBDzB";
    publicKey = "${publicKeyWithoutEmail} ${email}";
  };
}
