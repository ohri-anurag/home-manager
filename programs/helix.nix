{ pkgs }:
{
  enable = true;
  defaultEditor = true;
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
    keys.normal = {
      "F2" = ":! wl-copy %{buffer_name}";
    };
  };
  languages = {
    language-server = {
      sky-lsp = {
        command = "sky";
        args = [
          "lsp"
          "--stdio"
        ];
      };
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
      pls = {
        command = "postgres-language-server";
        args = [ "lsp-proxy" ];
      };
      dls = {
        command = "docker-language-server";
        args = [
          "start"
          "--stdio"
        ];
      };
      sorbet = {
        command = "bash";
        args = [
          "-c"
          "$(bundle info --path sorbet-static)/libexec/sorbet tc --lsp --enable-all-beta-lsp-features --disable-watchman"
        ];
      };
    };
    grammar = [
      {
        name = "sky";
        source = {
          git = "https://github.com/anzellai/tree-sitter-sky";
          rev = "dbe7d4211ee34711fa001e7d5275aa1ce365002d";
        };
      }
    ];
    language = [
      {
        name = "sky";
        scope = "source.sky";
        file-types = [
          "sky"
          "skyi"
        ];
        auto-format = true;
        formatter = {
          command = "sky";
          args = [
            "fmt"
            "-"
          ];
        };
        language-servers = [ "sky-lsp" ];
        comment-token = "--";
        indent = {
          tab-width = 4;
          unit = " ";
        };
      }
      {
        name = "nix";
        auto-format = true;
        formatter.command = "${pkgs.nixfmt}/bin/nixfmt";
      }
      {
        name = "rust";
        formatter.command = "rustfmt";
      }
      {
        name = "typescript";
        auto-format = true;
        formatter = {
          command = "prettier";
          args = [
            "--parser"
            "typescript"
          ];
        };
      }
      {
        name = "ruby";
        language-servers = [ "sorbet" ];
        formatter = {
          command = "stree";
          args = [
            "format"
            "--plugins=plugin/single_quotes"
            "--print-width=100"
          ];
        };
        auto-format = true;
      }
      {
        name = "sql";
        language-servers = [ "pls" ];
      }
      {
        name = "dockerfile";
        language-servers = [ "dls" ];
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
          "scls"
        ];
        auto-format = true;
      }
      {
        name = "cabal";
        auto-format = true;
        formatter = {
          command = "cabal-gild";
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
