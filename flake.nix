{
  description = "Dev machine setup";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixvim = {
        url = "github:nix-community/nixvim";
        # If using a stable channel you can use `url = "github:nix-community/nixvim/nixos-<version>"`
        inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, nixvim, ... }: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      modules = [
        ./configuration.nix
        home-manager.nixosModules.home-manager
	nixvim.nixosModules.nixvim
        {
          home-manager.backupFileExtension = "backup";
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.rspo = ./home.nix;
        }
	{
	  programs.nixvim = {
            enable = true;
            defaultEditor = true;
            viAlias = true;
            vimAlias = true;
	    opts = {
              number = true;         # Show line numbers
              relativenumber = true; # Show relative line numbers
              shiftwidth = 2;        # Tab width should be 2
            };
	    plugins = {
	      lazy = {
		enable = false;
	      };
	    };
	    colorschemes.rose-pine = {
	      enable = true;
	      settings.variant = "moon";
	    };
          };
	}
      ];
    };
  };
}

