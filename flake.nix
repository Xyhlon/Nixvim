{
  description = "A nixvim configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = {
    nixpkgs,
    nixvim,
    flake-parts,
    ...
  } @ inputs:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];

      perSystem = {
        pkgs,
        system,
        ...
      }: let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
        nixvimLib = nixvim.lib.${system};
        nixvim' = nixvim.legacyPackages.${system};
        nixvimModule = {
          inherit pkgs;
          module = import ./config; # import the module directly
          # You can use `extraSpecialArgs` to pass additional arguments to your module files
          extraSpecialArgs = {
            # inherit (inputs) foo;
          };
        };
        checkModule = {
          inherit pkgs;
          module = {lib, ...}: {
            imports = [
              (import ./config)
            ];

            # image.nvim needs a real terminal, so do not load it in nix flake check.
            plugins.image.enable = lib.mkForce false;
          };
          extraSpecialArgs = {};
        };
        nvim = nixvim'.makeNixvimWithModule nixvimModule;
      in {
        _module.args.pkgs = pkgs;
        checks = {
          # Run `nix flake check .` to verify that your config is not broken
          default = nixvimLib.check.mkTestDerivationFromNixvimModule checkModule;
        };

        packages = {
          # Lets you run `nix run .` to start nixvim
          default = nvim;
        };
        devShells.default = pkgs.mkShell {
          packages = [
            pkgs.statix
            pkgs.selene
            pkgs.alejandra
          ];
        };

        formatter = pkgs.alejandra;
      };
      flake = {
        nixosModules.default = {
          config,
          pkgs,
          lib,
          ...
        }: {
          imports = [inputs.nixvim.nixosModules.nixvim];
          programs.nixvim = import ./config/default.nix {inherit pkgs lib config;};
        };

        homeManagerModules.default = {
          config,
          pkgs,
          lib,
          ...
        }: {
          imports = [inputs.nixvim.homeModules.nixvim];
          programs.nixvim = import ./config/default.nix {inherit pkgs lib config;};
        };

        darwinModules.default = {
          config,
          pkgs,
          lib,
          ...
        }: {
          imports = [inputs.nixvim.darwinModules.nixvim];
          programs.nixvim = import ./config/default.nix {inherit pkgs lib config;};
        };
      };
    };
}
