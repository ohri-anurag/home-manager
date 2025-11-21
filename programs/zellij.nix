{
  enable = true;
  settings = {
    show_startup_tips = false;
    pane_frames = false;
    ui = {
      pane_frames = {
        hide_session_name = true;
      };
    };
    default_layout = "compact";
    keybinds = {
      unbind = [
        "Ctrl q"
        "Ctrl n"
        "Ctrl p"
        "Ctrl h"
        "Ctrl i"
        "Ctrl o"
        "Ctrl b"
        "Ctrl t"
        "Ctrl g"
      ];
      normal = {
        "bind \"Alt t\"" = {
          NewTab = [ ];
        };
        "bind \"Alt p\"" = {
          NewPane = [ ];
        };
        "bind \"Alt q\"" = {
          Quit = [ ];
        };
      };
    };
  };
}
