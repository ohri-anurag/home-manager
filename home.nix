{
  config,
  pkgs,
  nixgl,
  ...
}:
let
  claude-code = pkgs.buildNpmPackage {
    pname = "claude-code";
    version = "0.0.1";
    src = ./claude-code;
    npmDepsHash = "sha256-zG/g6lRtbx3terlb3nPyx9wg0bbjSScTyqOqh5jtFn0=";
    dontNpmBuild = true;
    postInstall = ''
      mkdir -p "$out/bin"
      ln -s "$out/lib/node_modules/claude-code/node_modules/@anthropic-ai/claude-code/cli.js" "$out/bin/claude"
    '';
  };
in
{
  nixGL.packages = import nixgl { inherit pkgs; };
  nixGL.defaultWrapper = "nvidia";
  nixGL.installScripts = [ "nvidia" ];

  home = {
    # Home Manager needs a bit of information about you and the
    # paths it should manage.
    username = "anuragohri92";
    homeDirectory = "/home/anuragohri92/";

    # This value determines the Home Manager release that your
    # configuration is compatible with. This helps avoid breakage
    # when a new Home Manager release introduces backwards
    # incompatible changes.
    #
    # You can update Home Manager without changing this value. See
    # the Home Manager release notes for a list of state version
    # changes in each release.
    stateVersion = "25.05";

    packages = with pkgs; [
      bat # Cat with wings
      btop # System monitor
      claude-code # Setup for claude code
      cmus # Music player
      difftastic # Semantic diff tool
      fd # Faster find
      gh # GitHub CLI
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

  nixpkgs.config = {
    allowUnfree = true;
  };
}
