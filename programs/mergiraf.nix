{ lib, pkgs, ... }:
{
  enable = true;
  package = pkgs.rustPlatform.buildRustPackage {
    pname = "mergiraf";
    version = "0.10.0";

    src = pkgs.fetchFromGitea {
      domain = "codeberg.org";
      owner = "mergiraf";
      repo = "mergiraf";
      rev = "7041d559317a0131e9018ef2fade6a60e75388c8";
      hash = "sha256-DpJEoRIr2uVJRQGRByMJXqLG+EzXQqeI7hDZtmp/NJk=";
    };

    useFetchCargoVendor = true;
    cargoHash = "sha256-dc22h0ST1UDnsURZsaZ4WM1zj1kbJbWc8obXXaheE3A=";

    nativeCheckInputs = [
      pkgs.git
    ];

    doInstallCheck = true;
    nativeInstallCheckInputs = [
      pkgs.versionCheckHook
    ];

    versionCheckProgramArg = "--version";

    meta = {
      description = "Syntax-aware git merge driver for a growing collection of programming languages and file formats";
      homepage = "https://mergiraf.org/";
      changelog = "https://codeberg.org/mergiraf/mergiraf/releases/tag/v0.10.0";
      license = lib.licenses.gpl3Only;
      maintainers = with lib.maintainers; [
        zimbatm
        genga898
      ];
      mainProgram = "mergiraf";
    };
  };
}
