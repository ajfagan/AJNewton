{ pkgs ? import <nixpkgs> {} }:
let 
  unstable = import (fetchTarball "https://nixos.org/channels/nixos-unstable/nixexprs.tar.xz") { };
  RwithPackages = unstable.rWrapper.override {
    packages = with unstable.rPackages; [
      # httpuv
      # shiny
      dplyr
      # rlang
      # purrr
      tidyverse
      pheatmap
      colourpicker
      # bslib
      ggplot2
      DESeq2
      # colorspace
      #pathfindR
      # textshaping
      # BiocManager
      SummarizedExperiment
      # pathfindR
    ] ++ (with pkgs.rPackages; [
      #tidyverse
      #colourpicker
    ]);
  };
in
  unstable.mkShell {
    nativeBuildInputs = [
      RwithPackages
      #pkgs.R
      #pkgs.zlib
      #pkgs.libxml2.dev
      #pkgs.harfbuzz
      #pkgs.freetype
      #pkgs.fribidi
      #pkgs.pkg-config
      #pkgs.libpng
      #pkgs.libtiff
      #pkgs.libjpeg
    ];
    buildInputs = [
      #pkgs.dbus
      #pkgs.freetype
      #pkgs.jdk11
    ];
    #shellHook = #''
      #export JAVA_HOME=${pkgs.jdk11}
      #PATH="${pkgs.jdk11}/bin:$PATH"
      #echo ${pkgs.jdk11}
    #'';
  }
