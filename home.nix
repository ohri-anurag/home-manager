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
          | concat { "due": "#2", "description": "#1" }
          | appendfile ${user.homeDirectory}/.taskfile
          | sort -o ${user.homeDirectory}/.taskfile ${user.homeDirectory}/.taskfile
        '';
      };
      "build.bask" = {
        text = ''
          cd ${user.bellroy.rootDir}/haskell/
          | echo -e "optimization: False\nprogram-options\n  ghc-options: -Wall"
          | writefile cabal.project.local
          | git ls-files --other --exclude-standard -- *.hs || git diff --name-only --diff-filter=d -- '*.hs'
          | concat #1#2
          | xargs hlint -h .hlint.yaml
          | show cabal --builddir=dist-newstyle build $1
          | show cabal --builddir=dist-newstyle test $1
        '';
      };
      "debug.bask" = {
        text = ''
          cd ${user.bellroy.rootDir}/haskell/
          | echo -e "optimization: False\nprogram-options\n  ghc-options: -Wwarn -Wunused-top-binds -Werror=unused-top-binds"
          | writefile cabal.project.local
          | fd .*.cabal\$ .
          | fzf -f "$1"
          | head -n 1
          | dirname #1
          | cd #1
          | if $2 then $1:$2 else $1
          | show ghcid -c "cabal --builddir=${user.bellroy.rootDir}/haskell/dist-newstyle-debug repl #1" -o ghcid.txt
        '';
      };
      "cover.bask" = {
        text = ''
          cd ${user.bellroy.rootDir}/haskell/
          | echo -e "optimization: False\nprogram-options\n  ghc-options: -Wall\npackage *\n  coverage: True\n  library-coverage: True\n\npackage order-processing\n  coverage: False\n  library-coverage: False"
          | writefile cabal.project.local
          | show cabal --builddir=dist-newstyle-cover build $1
          | show cabal --builddir=dist-newstyle-cover test $1
        '';
      };
      "repl.bask" = {
        text = ''
          cd ${user.bellroy.rootDir}/haskell/
          | echo -e "optimization: False\nprogram-options\n  ghc-options: -Wwarn -Wunused-top-binds -Werror=unused-top-binds"
          | writefile cabal.project.local
          | fd .*.cabal\$ .
          | fzf -f "$1"
          | head -n 1
          | dirname #1
          | cd #1
          | if $2 then $1:$2 else $1
          | interact cabal --builddir=/home/anuragohri92/bellroy/haskell/dist-newstyle-debug repl #1
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
          version = "2.0.14";
          src = pkgs.fetchzip {
            url = "https://registry.npmjs.org/@anthropic-ai/claude-code/-/claude-code-${version}.tgz";
            hash = "sha256-U/wd00eva/qbSS4LpW1L7nmPW4dT9naffeMkHQ5xr5o=";
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
        haskellPackages.hasktags # Generate CTAGS for Haskell
        jq # CLI JSON processor
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
    ssh-agent.enable = true;
  };

  xdg.configFile = {
    "git/allowedSigners".text = "${user.bellroy.email} ${user.bellroy.publicKeyWithoutEmail}";
  };
}
