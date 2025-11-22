{
  description = "icy's NixOS config (Hyprland + gaming + dev)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
 
    spicetify-nix.url = "github:Gerg-L/spicetify-nix"; 

    stylix.url = "github:nix-community/stylix/release-25.05";

    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
  let
    system = "x86_64-linux";
    lib = nixpkgs.lib;
  in {
    nixosConfigurations.icebox = lib.nixosSystem {
      inherit system;

      specialArgs = { inherit inputs; };

      modules = [
        ./hosts/icebox/configuration.nix
        ./hosts/icebox/hardware-configuration.nix
        inputs.stylix.nixosModules.stylix
    
	./modules/stylix.nix
        ./modules/desktop/hyprland.nix
        ./modules/gaming.nix
        ./modules/dev.nix
  	./modules/security.nix
	./modules/secure-boot.nix
	./modules/bluetooth.nix

        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = { inherit inputs; };

          home-manager.users.icy = import ./home/icy/default.nix;
        }
      ];
    };
  };
}

