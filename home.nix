{
  config,
  pkgs,
  nixgl,
  lib,
  ...
}:
{
  nixGL.packages = nixgl.packages;
  nixGL.defaultWrapper = "nvidia";
  nixGL.installScripts = [ "nvidia" ];

  home = {
    # Home Manager needs a bit of information about you and the
    # paths it should manage.
    username = "anuragohri92";
    homeDirectory = "/home/anuragohri92/";

    file = {
      yubikey.source = builtins.fetchTarball {
        url = "https://developers.yubico.com/yubioath-flutter/Releases/yubico-authenticator-latest-linux.tar.gz";
        sha256 = "sha256:10l3ixgnalm04jvx22qs9mmysqk2iq64vkkadlk3di2lhln8n6kw";
      };
    };

    # This value determines the Home Manager release that your
    # configuration is compatible with. This helps avoid breakage
    # when a new Home Manager release introduces backwards
    # incompatible changes.
    #
    # You can update Home Manager without changing this value. See
    # the Home Manager release notes for a list of state version
    # changes in each release.
    stateVersion = "25.05";

    packages =
      let
        # Setup for claude code
        claude-code = pkgs.claude-code.overrideAttrs (_: rec {
          version = "1.0.6";
          src = pkgs.fetchzip {
            url = "https://registry.npmjs.org/@anthropic-ai/claude-code/-/claude-code-${version}.tgz";
            hash = "sha256-yMvx543OOClV/BSkM4/bzrbytL+98HAfp14Qk1m2le0=";
          };
        });
      in
      with pkgs;
      [
        bat # Cat with wings
        btop # System monitor
        claude-code
        cmus # Music player
        difftastic # Semantic diff tool
        fd # Faster find
        gh # GitHub CLI
        glow # CLI markdown renderer
        gum # CLI Tool for making awesome bash scripts
        haskellPackages.hasktags # Generate CTAGS for Haskell
        httpie # CLI HTTP client
        jq # CLI JSON processor
        keepassxc # Password manager
        nerd-fonts.hasklug # Hasklug Nerd Font
        nicotine-plus # Client for Soulseek
        nil # Nix language server
        nixfmt-rfc-style # Nix formatter
        node2nix # For generating flakes for node packages
        nodePackages.nodejs # NodeJS
        ouch # Zipping/Unzipping CLI tool
        pavucontrol # PulseAudio volume control
        ripgrep # Faster grep
        stylua # Lua formatter
        xclip # Clipboard manager
      ];
  };

  programs = {
    bash = import ./programs/bash.nix;

    # Environment switcher
    direnv = {
      enable = true;
      enableBashIntegration = true;
    };

    # Fuzzy finder
    fzf = {
      enable = true;
      enableBashIntegration = true;
    };

    ghostty = import ./programs/ghostty.nix { inherit config pkgs; };

    git = import ./programs/git.nix;

    # Let Home Manager install and manage itself.
    home-manager.enable = true;

    mergiraf = import ./programs/mergiraf.nix {
      inherit pkgs lib;
    };

    neovim = import ./programs/neovim.nix {
      inherit pkgs;
    };

    ssh = {
      addKeysToAgent = "yes";
      enable = true;
      extraOptionOverrides = {
        IdentityFile = "~/.ssh/id_ed25519";
      };
      matchBlocks = {
        "*.trikeapps.com" = {
          user = "anurag";
        };
      };
      package = pkgs.openssh.override { withKerberos = true; };
    };

    starship = import ./programs/starship.nix;

    # File manager
    yazi = import ./programs/yazi.nix;
  };

  services = {
    ssh-agent.enable = true;
  };

  xdg.configFile = {
    "git/allowedSigners".text =
      "anurag.ohri@bellroy.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB4L1Uado9BQOqZVhSebRRxGojB1gde2cnrMAlrUBDzB";
  };
}
