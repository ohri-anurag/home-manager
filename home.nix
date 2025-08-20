{
  pkgs,
  user,
  bask,
  ...
}:
{
  home = {
    # Home Manager needs a bit of information about you and the
    # paths it should manage.
    inherit (user) username homeDirectory;

    file = {
      "task.bask" = {
        text = ''
          readline What needs doing? || readline When is it due?
          | passthru || date -u +%Y-%m-%dT%H:%M:%SZ -f -
          | passthru || tr -d '\n'
          | reorder 2 1
          | merge { "due": "pipe", "description": "pipe" }
          | appendfile ${user.homeDirectory}/.taskfile
          | sort -o ${user.homeDirectory}/.taskfile ${user.homeDirectory}/.taskfile
        '';
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
          version = "1.0.38";
          src = pkgs.fetchzip {
            url = "https://registry.npmjs.org/@anthropic-ai/claude-code/-/claude-code-${version}.tgz";
            hash = "sha256-flG9VlnQfMfGFBbs6RdQKSbceD/Tke19Euo8znR5OG0=";
          };
        });
      in
      with pkgs;
      [
        awscli2 # AWS CLI
        bask # Framework for executing CLI commands
        bat # Cat with wings
        btop # System monitor
        claude-code
        curlie # CLI HTTP client
        difftastic # Semantic diff tool
        fd # Faster find
        gh # GitHub CLI
        glow # CLI markdown renderer
        gum # CLI Tool for making awesome bash scripts
        haskellPackages.hasktags # Generate CTAGS for Haskell
        jq # CLI JSON processor
        libnotify # For notify-send
        libxml2 # XML Tools
        nerd-fonts.hasklug # Hasklug Nerd Font
        nil # Nix language server
        nix-output-monitor # Better nix build
        nixfmt-rfc-style # Nix formatter
        openssl # Crypto tools
        ouch # Zipping/Unzipping CLI tool
        parallel # CLI tool for parallelisation
        ripgrep # Faster grep
        stylua # Lua formatter
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

    # Let Home Manager install and manage itself.
    home-manager.enable = true;

    mergiraf.enable = true;

    neovim = import ./programs/neovim.nix {
      inherit pkgs;
    };

    ssh = {
      addKeysToAgent = "yes";
      enable = true;
      extraOptionOverrides = {
        IdentityFile = user.bellroy.ssh.privateKeyPath;
      };
      matchBlocks = {
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
    mako.enable = true;
    ssh-agent.enable = true;
  };

  xdg.configFile = {
    "git/allowedSigners".text = "${user.bellroy.email} ${user.bellroy.publicKeyWithoutEmail}";
  };
}
