{
  description = "A basic flake with a shell";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs =
    { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = pkgs.mkShell { 
	  packages = with pkgs; [ 
	    bashInteractive
	    jdk11
	    (rstudioWrapper.override {
	      packages = with pkgs.rPackages; 
	      let allez = buildRPackage {
		name = "allez";
		src = fetchFromGitHub {
		  owner = "wiscstatman";
		  repo = "allez";
		  rev = "3f9f40acfd5b85ae9f6b599eb67d2fd987030a76";
		  hash =  "sha256-6tQ3chYHCPDkLg1LllenETptvolXtPcF6XWrg47orno=";
		};
		propogatedBuildInputs = [ rlang AnnotationDbi ];
		nativeBuildInputs = [ rlang AnnotationDbi ];
	      };
	      in 
		[
		  ggplot2
		  dplyr
		  org_Hs_eg_db
		  DESeq2
		  pheatmap
		  RColorBrewer
		  allez
		  rmarkdown
		  knitr
		  pathfindR
		];
	    })
	  ]; 
	  buildInputs = with pkgs; [ jdk11 ];
	  shellHook = ''
	    export JAVA_HOME=${pkgs.jdk11}
	    PATH="${pkgs.jdk11}/bin:$PATH"
	  '';
	};
      }
    );
}
