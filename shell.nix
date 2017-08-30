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
    function dl_gluon () {
      if [ "$#" -ne 3 ]; then
        echo ERROR: Specify gluon branch, site name and site branch >&2
        echo        example: dl_gluon v2015.1.x ffhh 0.7.x
        return 1
      fi
      local gluonbranch="$1"
      local gluonsite="$2"
      local gluonsitebranch="$3"
      local gluondir="$PWD/gluon-$gluonbranch-$gluonsite-$gluonsitebranch"
      local gluongit=$(awk -v SITE=gluon '$1 == SITE {print $2}' sites-gluon)
      local sitegit=$(awk -v SITE=$2 '$1 == SITE {print $2}' sites-gluon)

      echo Preparing directory $gluondir...
      rmdir "$gluondir" 2>/dev/null
      [ -e "$gluondir" ] && {
        echo ERROR: $gluondir already exists >&2
        return 1
      }
      mkdir -p "$gluondir"

      echo Downloading gluon...
      git clone -b "$gluonbranch" $gluongit "$gluondir"
      cd "$gluondir" || return 1
      touch .nobackup
      #patchShebangs scripts

      echo Downloading site from $sitegit...
      git clone -b "$gluonsitebranch" "$sitegit" site

      echo Updating...
      make update
      #patchShebangs openwrt/scripts

      # Listing available targets...
      make
      echo Done. You can compile using make setting the target you need \(see above for targets\).
      echo '$ make -d GLUON_TARGET=ar71xx-generic V=s'
    }
    export -f dl_gluon
    echo Setting up build environment...
    export LANG=C
    export C_INCLUDE_PATH=/usr/include
    export LIBRARY_PATH=/lib
    export NIX_CFLAGS_COMPILE="-I/usr/include"
    export NIX_CFLAGS_LINK="-L/usr/lib64 -L/usr/lib32"
    export hardeningDisable="all"
    unset SSL_CERT_FILE
    echo Use dl_gluon to setup a specific version
  '';
}).env
