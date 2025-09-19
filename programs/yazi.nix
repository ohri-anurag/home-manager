{
  enable = true;
  enableBashIntegration = true;
  settings = {
    mgr = {
      show_hidden = true;
      sort_dir_first = true;
    };
    opener.edit = [
      {
        run = "nvim '$@'";
        block = true;
      }
    ];
  };
  theme = {
    icon.prepend_rules = [
      {
        name = "*.txt";
        text = "󰈙";
        fg = "blue";
      }
      {
        name = "*.lock";
        text = "󰌾";
        fg = "yellow";
      }
      {
        name = "*.yml";
        text = "󰈙";
        fg = "red";
      }
      {
        name = "*.yaml";
        text = "󰈙";
        fg = "red";
      }
      {
        name = "*.hs";
        text = "";
        fg = "#5e5086";
      }
      {
        name = "*.lhs";
        text = "";
        fg = "#5e5086";
      }
      {
        name = "*.ghci";
        text = "";
        fg = "darkgray";
      }
      {
        name = "*.gitignore";
        text = "󰊢";
        fg = "red";
      }
      {
        name = "*.gitattributes";
        text = "󰊢";
        fg = "red";
      }
      {
        name = "*.gitmodules";
        text = "󰊢";
        fg = "red";
      }
      {
        name = "*.sh";
        text = "";
        fg = "red";
      }
      {
        name = "*.envrc";
        text = "";
        fg = "red";
      }
      {
        name = "*tags";
        text = "󱤇";
        fg = "green";
      }
      {
        name = "*.cabal";
        text = "󰘧";
        fg = "#5e5086";
      }
      {
        name = "*.cabal";
        text = "󰘧";
        fg = "#5e5086";
      }
      {
        name = "*cabal.project*";
        text = "󰘧";
        fg = "#5e5086";
      }
      {
        name = "*readme*";
        text = "󰋼";
        fg = "blue";
      }
      {
        name = "*.dhall";
        text = "";
        fg = "darkgray";
      }
    ];
  };
}
