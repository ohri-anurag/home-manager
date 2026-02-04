{ pkgs }:
{
  enable = true;
  extraPackages = [ pkgs.simple-completion-language-server ];
  settings = {
    theme = "moonfly";
    editor = {
      color-modes = true;
      indent-guides = {
        render = true;
      };
      search = {
        smart-case = false;
      };
    };
  };
  languages = {
    language-server = {
      hls = {
        command = "haskell-language-server";
      };
      scls = {
        command = "simple-completion-language-server";
        config = {
          feature_words = true;
          feature_snippets = false;
        };
      };
    };
    language = [
      {
        name = "nix";
        auto-format = true;
        formatter.command = "${pkgs.nixfmt-rfc-style}/bin/nixfmt";
      }
      {
        name = "rust";
        formatter.command = "rustfmt";
      }
      {
        name = "haskell";
        formatter = {
          command = "ormolu";
          args = [
            "--stdin-input-file"
            "%sh{pwd}/%{buffer_name}"
          ];
        };
        language-servers = [
          "hls"
          "scls"
        ];
        auto-format = true;
      }
      {
        name = "cabal";
        auto-format = true;
        formatter = {
          command = "cabal-fmt";
        };
      }
      {
        name = "json";
        auto-format = true;
        formatter = {
          command = "jq";
          args = [
            "."
          ];
        };
      }
    ];
  };
}
