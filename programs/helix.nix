{ pkgs }:
{
  enable = true;
  settings = {
    theme = "carbonfox";
    editor.indent-guides = {
      render = true;
    };
  };
  languages = {
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
        auto-format = true;
      }
    ];
  };
}
