{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, ... } @ inputs: 

    flake-utils.lib.eachDefaultSystem (
      system:
      let
	pkgs = nixpkgs.legacyPackages.${system};
      in 
      {
	devShells.default = pkgs.mkShell { 
	  packages = with pkgs; [
	    # bashInteractive
	    imagej
	  ]; 
	};
      }
    );
}
