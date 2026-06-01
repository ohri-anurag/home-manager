{
  pkgs,
  user,
  ...
}:
{
  home = {
    # Home Manager needs a bit of information about you and the
    # paths it should manage.
    inherit (user) username homeDirectory;

    # This value determines the Home Manager release that your
    # configuration is compatible with. This helps avoid breakage
    # when a new Home Manager release introduces backwards
    # incompatible changes.
    #
    # You can update Home Manager without changing this value. See
    # the Home Manager release notes for a list of state version
    # changes in each release.
    stateVersion = "26.05";

    packages =
      let
        claude-code = pkgs.stdenv.mkDerivation rec {
          name = "claude-code";
          version = "2.1.159";
          src = builtins.fetchurl {
            # URL for checking latest version: https://storage.googleapis.com/claude-code-dist-86c565f3-f756-42ad-8dfa-d59b1c096819/claude-code-releases/latest
            url = "https://storage.googleapis.com/claude-code-dist-86c565f3-f756-42ad-8dfa-d59b1c096819/claude-code-releases/${version}/linux-x64/claude";
            sha256 = "sha256:0h9mgrgxjfr651bsrcjna8c336vyiijlg6d2f69w0gpd02pnq4p2";
          };

          phases = [ "installPhase" ];

          installPhase = ''
            mkdir -p $out/bin
            cp $src $out/bin/claude
            chmod +x $out/bin/claude
          '';
        };
        kilocode-cli = pkgs.stdenv.mkDerivation rec {
          name = "kilocode-cli";
          version = "7.3.16";
          src = builtins.fetchurl {
            # URL for checking latest version: https://storage.googleapis.com/claude-code-dist-86c565f3-f756-42ad-8dfa-d59b1c096819/claude-code-releases/latest
            url = "https://github.com/Kilo-Org/kilocode/releases/download/v${version}/kilo-linux-x64.tar.gz";
            sha256 = "sha256:02mh4p73bzwc0q1drvikl78japxq30lhnry9msp71m4vaydxyz62";
          };

          phases = [ "installPhase" ];

          installPhase = ''
            mkdir -p $out/bin
            tar -xf $src -C $out/bin
            chmod +x $out/bin/kilo
          '';
        };
        todo = pkgs.stdenv.mkDerivation rec {
          name = "todo";
          version = "0.1.2.0";
          src = builtins.fetchurl {
            url = "https://github.com/ohri-anurag/todo-cli/releases/download/v${version}/todo";
            sha256 = "sha256-d4nVRIlxSK64Ge5wKzWIY2+p1vsWxKGlEkV/vEVkZGM=";
          };
          phases = [ "installPhase" ];
          installPhase = ''
            mkdir -p $out/bin
            cp $src $out/bin/todo
            chmod +x $out/bin/todo
          '';
        };
      in
      with pkgs;
      [
        awscli2 # AWS CLI
        aws-sso-util # To make managing AWS SSO easier
        bat # Cat with wings
        btop # System monitor
        claude-code
        curlie # CLI HTTP client
        dbeaver-bin # DB GUI Client
        difftastic # Semantic diff tool
        docker-language-server # Docker LSP
        fd # Faster find
        gh # GitHub CLI
        glow # CLI markdown renderer
        jq # CLI JSON processor
        kilocode-cli
        libxml2 # XML Tools
        lynx # Display HTML in terminal
        nerd-fonts.hasklug # Hasklug Nerd Font
        nil # Nix language server
        nix-output-monitor # Better nix build
        nixfmt # Nix formatter
        nushell # New way to shell
        openssl # Crypto tools
        ouch # Zipping/Unzipping CLI tool
        ripgrep # Faster grep
        stylua # Lua formatter
        todo # todo cli
        postgres-language-server # Postgresql LSP
        wl-clipboard # Clipboard for NeoVim
      ];
  };

  programs = {
    bash = import ./programs/bash.nix { inherit user; };

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

    foot = import ./programs/foot.nix;

    git = import ./programs/git.nix { inherit user; };

    helix = import ./programs/helix.nix { inherit pkgs; };

    # Let Home Manager install and manage itself.
    home-manager.enable = true;

    jujutsu = {
      enable = true;
      settings = {
        user = {
          email = user.bellroy.email;
          name = user.name;
        };
        signing = {
          behavior = "own";
          backend = "ssh";
          backends.ssh.allowed-signers = "${user.homeDirectory}/.config/git/allowedSigners";
          key = "${user.homeDirectory}/.ssh/id_ed25519.pub";
        };
        ui = {
          movement.edit = true;
          diff-formatter = [
            "difft"
            "--color=always"
            "$left"
            "$right"
          ];
        };
      };
    };

    lazygit = {
      enable = true;
      settings = {
        gui = {
          theme = {
            selectedLineBgColor = [ "default" ];
          };
        };
      };
    };

    lazysql.enable = true;
    mergiraf.enable = true;

    neovim = import ./programs/neovim.nix {
      inherit pkgs;
    };

    ssh = {
      enable = true;
      enableDefaultConfig = false;
      extraOptionOverrides = {
        IdentityFile = user.bellroy.ssh.privateKeyPath;
      };
      settings = {
        "*" = {
          addKeysToAgent = "yes";
          userKnownHostsFile = "~/.ssh/known_hosts";
        };
        "*.trikeapps.com" = {
          inherit (user.bellroy.ssh) user;
        };
      };
      package = pkgs.openssh.override { withKerberos = true; };
    };

    starship = import ./programs/starship.nix;

    # File manager
    yazi = import ./programs/yazi.nix;

    zellij = import ./programs/zellij.nix;
  };

  services = {
    ssh-agent.enable = true;
  };

  xdg.configFile = {
    "git/allowedSigners".text = "${user.bellroy.email} ${user.bellroy.publicKeyWithoutEmail}";

    "helix/themes/moonfly.toml".source = pkgs.fetchurl {
      url = "https://gist.githubusercontent.com/ohri-anurag/2a567f281e023b6a31dbae0e2f018bbe/raw/255dd252fc4cc9aa7031177e3601a48e48bd81bc/moonfly.toml";
      sha256 = "sha256-6xy5P2ii20xyfNYp2R9mLR4es8AVgt4FTLoAW63CKNw=";
    };

    "zellij/themes/moonfly.kdl".source = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/bluz71/vim-moonfly-colors/refs/heads/master/extras/moonfly-zellij.kdl";
      sha256 = "sha256-dWM2ET8wnfmOlakctkTkL74uGc6Fyes5Ta4aT7J2xM4=";
    };
  };
}
