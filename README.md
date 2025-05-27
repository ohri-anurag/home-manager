# Home Manager Configuration
This repository contains my personal Home Manager configuration, which is used to manage my user environment.

## Steps

1. rm -rf ~/.config/home-manager
2. Clone this repositoy inside ~/.config
3. Run the following command to switch to the new configuration:
```bash
NIXPKGS_ALLOW_UNFREE=1 home-manager switch --impure
````
