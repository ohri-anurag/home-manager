{
  enable = true;
  enableBashIntegration = true;
  settings = {
    palette = "moonfly";
    c.style = "green";
    character = {
      success_symbol = "[❯](blue)";
      error_symbol = "[❯](red)";
    };
    directory = {
      truncation_length = 4;
      truncation_symbol = "…/";
      style = "fern";
    };
    git_branch.style = "lavender";
    package.style = "orange";
    perl.style = "green";
    swift.style = "red";
    terraform.style = "purple";
    palettes.moonfly = {
      fern = "#87d787";
      lavender = "#adadf3";
      orange = "#f09479";
      red = "#f07496";
    };
  };
}
