{
  description = "Home Manager configuration of anuragohri92";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-25.05-darwin";
    nixgl = {
      url = "github:nix-community/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
      flake = false;
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      nixgl,
      home-manager,
      ...
    }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      nixGL =
        let
          nixgldefaultnix = import nixgl {
            inherit pkgs;
            enable32bits = true;
            enableIntelX86Extensions = true;
            nvidiaVersion = "550.144.03";
            nvidiaHash = "sha256-akg44s2ybkwOBzZ6wNO895nVa1KG9o+iAb49PduIqsQ=";
          };
        in
        rec {
          packages = {
            # makes it easy to use "nix run nixGL --impure -- program"
            default = nixgldefaultnix.nixGLDefault;

            nixGLDefault = nixgldefaultnix.nixGLDefault;
            nixGLNvidia = nixgldefaultnix.nixGLNvidia;
            nixGLNvidiaBumblebee = nixgldefaultnix.nixGLNvidiaBumblebee;
            nixGLIntel = nixgldefaultnix.nixGLIntel;
            nixVulkanNvidia = nixgldefaultnix.nixVulkanNvidia;
            nixVulkanIntel = nixgldefaultnix.nixVulkanIntel;
          };

          defaultPackage = packages;

        };

    in
    {
      homeConfigurations."anuragohri92" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        # Specify your home configuration modules here, for example,
        # the path to your home.nix.
        modules = [ ./home.nix ];

        # Optionally use extraSpecialArgs
        # to pass through arguments to home.nix
        extraSpecialArgs = {
          nixgl = nixGL;
        };

      };
    };
}
