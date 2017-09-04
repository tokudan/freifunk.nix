#!/usr/bin/env bash
set -e

# List of build targets
build_targets="ar71xx-generic ar71xx-nand mpc85xx-generic x86-generic"

# List of sites to build
site="ffhh"

# Gluon version
gluon_version="$1"

# Site version
site_version="$2"

# GIT URLs
git_gluon="https://github.com/freifunk-gluon/gluon.git"
git_site="https://github.com/freifunkhamburg/site-ffhh.git"

# Build directory
builddir="$(pwd)/firmware-${site}.$(date +%Y%m%dT%H%M%S)/${buildversion}"



# Check arguments
if [ -z "$1" -o -z "$2" ]; then
	cat <<-EOF
	Usage: $0 GLUON_VERSION SITE_VERSION
	EOF
	exit
fi


# Build process
mkdir -p "${builddir}"
cd "${builddir}" || exit 1

for target in $build_targets; do
	echo Starting build for $target >&2
	targetdir="${builddir}/${target}"
	mkdir -p "${targetdir}"
	cd "${targetdir}" || exit 2

	echo Downloading gluon... >&2
	git clone -b "${gluon_version}" "${git_gluon}" .
	touch .nobackup

	echo Downloading site configuration >&2
	git clone -b "${site_version}" "${git_site}" site

	echo Downloading modules for gluon and openwrt... >&2
	make update

	echo Building firmware for $target >&2
	nice make -j$(($(nproc) + 1)) GLUON_TARGET=${target} GLUON_BRANCH=experimental GLUON_REGION=eu &
done
for target in $build_targets; do
	wait
done
