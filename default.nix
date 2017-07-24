{ pkgs ? import <nixpkgs> {} }:

(pkgs.buildFHSUserEnv {
	name = "fffirmware-env";
	multiPkgs = pkgs: (with pkgs;
		[
			bzip2
			curl
			file
			gawk
			gcc
			gcc
			getopt
			git
			gnumake
			ncurses
			openssh
			openssl
			openssl
			patch
			perl
			pkgconfig
			python
			subversion
			unzip
			vim
			wget
			which
			zlib
		]);
	runScript = "bash";
	profile = ''
	function dl_gluon () {
		if [ "$#" -ne 3 ]; then
			echo ERROR: Specify gluon branch, site name and site branch >&2 
			echo				example: dl_gluon v2015.1.x ffhh 0.7.x
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
	export C_INCLUDE_PATH=/usr/include
	export LIBRARY_PATH=/lib
	export NIX_CFLAGS_COMPILE="-I/usr/include"
	export NIX_CFLAGS_LINK="-L/usr/lib64 -L/usr/lib32"
	unset SSL_CERT_FILE
	echo Use dl_gluon to setup a specific version
	'';
}).env