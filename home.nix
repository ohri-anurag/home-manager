{
  pkgs,
  lib,
  user,
  ...
}:
{
  home = {
    # Home Manager needs a bit of information about you and the
    # paths it should manage.
    inherit (user) username homeDirectory;

    file = {
      # This is needed in a separate file because crontab doesn't take my .bashrc into account
      # I need to run this as a file, and not as a bash command
      "notify.sh" = {
        executable = true;
        text = ''
          TASKS_FILE=${user.homeDirectory}/tasks.json
          if [[ -f $TASKS_FILE ]]
          then
            jq '.[]' -c $TASKS_FILE | while read task; do
              DUE=$(date +%s -d "$(echo $task | jq -r '.due')")
              if [[ $(date -u +%s) -gt $DUE ]]
              then
                DESC=$(echo $task | jq -r '.desc')
                ID=$(echo $task | jq -r '.id')
                XDG_RUNTIME_DIR=/run/user/$(id -u) notify-send --app-name "TODO" -t 0 "Task due: $ID" "$DESC"
                XDG_RUNTIME_DIR=/run/user/$(id -u) paplay /usr/share/sounds/freedesktop/stereo/complete.oga
              fi
            done
          fi
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
          version = "1.0.33";
          src = pkgs.fetchzip {
            url = "https://registry.npmjs.org/@anthropic-ai/claude-code/-/claude-code-${version}.tgz";
            hash = "sha256-AH/ZokL0Ktsx18DrpUKgYrZKdBnKo29jntwXUWspH8w=";
          };
        });
      in
      with pkgs;
      [
        awscli2 # AWS CLI
        bat # Cat with wings
        btop # System monitor
        claude-code
        difftastic # Semantic diff tool
        fd # Faster find
        gh # GitHub CLI
        glow # CLI markdown renderer
        gum # CLI Tool for making awesome bash scripts
        haskellPackages.hasktags # Generate CTAGS for Haskell
        httpie # CLI HTTP client
        jq # CLI JSON processor
        nerd-fonts.hasklug # Hasklug Nerd Font
        nil # Nix language server
        nixfmt-rfc-style # Nix formatter
        ouch # Zipping/Unzipping CLI tool
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

    ghostty = import ./programs/ghostty.nix;

    git = import ./programs/git.nix { inherit user; };

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
  };

  services = {
    ssh-agent.enable = true;
  };

  xdg.configFile = {
    "git/allowedSigners".text = "${user.bellroy.email} ${user.bellroy.publicKeyWithoutEmail}";
  };
}
