{
  description = "Your new nix config";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    disko.url = "github:nix-community/disko";
    home-manager.url = "github:nix-community/home-manager";
    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
    nixpkgs-xr.url = "github:nix-community/nixpkgs-xr";
    steam-config-nix = {
      url = "github:different-name/steam-config-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      };
    
  };

  outputs = inputs: {
    # NixOS configuration entrypoint
    # Available through 'nixos-rebuild --flake .#your-hostname'
    nixosConfigurations = {
      iridium = inputs.nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          ./configuration.nix
          inputs.disko.nixosModules.default
          ./disko.nix
          inputs.home-manager.nixosModules.home-manager
        ];
      };
    };
  };
}
