#!/usr/bin/env nix-shell

{ pkgs ? import <nixpkgs> {} }:

(pkgs.buildFHSUserEnv {
  name = "fffirmware-env";
  multiPkgs = pkgs: (with pkgs;
    [
      bzip2 bzip2.bin bzip2.dev bzip2.man
      curl curl.bin curl.dev curl.devdoc curl.man
      file
      gawk gawk.man gawk.info
      gcc
      getopt
      git
      gnumake gnumake.doc
      ncurses5 ncurses5.dev ncurses5.man
      openssh
      openssl openssl.bin openssl.dev openssl.man
      patch
      perl perl.devdoc perl.man
      pkgconfig
      python
      subversion subversion.dev subversion.man
      unzip
      vim
      wget
      which
      zlib zlib.dev
    ]);
  profile = ''
    echo Setting up build environment...
    export LANG=C
    export C_INCLUDE_PATH=/usr/include
    export LIBRARY_PATH=/lib
    export NIX_CFLAGS_COMPILE="-I/usr/include"
    export NIX_CFLAGS_LINK="-L/usr/lib64 -L/usr/lib32"
    export hardeningDisable="all"
    unset SSL_CERT_FILE
  '';
}).env
