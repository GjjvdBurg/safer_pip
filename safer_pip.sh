#!/bin/bash
#
##############################################################################
#                                                                            #
# Slightly safer way to install Python packages with pip.                    #
#                                                                            #
# This script downloads the package with pip, unzips it, and asks the user   #
# to check the contents of the setup.py file, to make sure no malicious code #
# is present there. When the user confirms this, the script installs the     #
# package locally for the user, and removes the downloaded package.          #
#                                                                            #
# Written by: Gertjan van den Burg                                           #
# Date: June 9, 2016                                                         #
# Licence: GPL v3.                                                           #
#                                                                            #
##############################################################################

###### Constants ######

# Define pip command
PIP="pip"
# Define unzip and tar command
UNZIP=unzip
TAR=tar
# Get package name
pkgname=$1
# Temporary and working directory
TMPDIR=$(mktemp -d)
working_dir=$(pwd)
# warning url
url="http://incolumitas.com/2016/06/08/typosquatting-package-managers/"

# Definitions for colour output
res='\033[1m\033[0m'
warn() { echo -e "\e[34m$*${res}"; }
log() { echo -e "\e[32m$*${res}"; }
err() { echo -e "\e[31m$*${res}"; exit 1; }

###### Downloading package ######
cd ${TMPDIR}

download() {
	log "Downloading package ... "
	${PIP} download --no-binary :all: ${pkgname}
}

###### Extracting package ######
extract() {
	case "$1" in
		*.tar.bz2)
			pkgfile=$(find . -type f -iname "*.tar.gz")
			log "Found package file: ${pkgfile}"
			log "Extracting package ... "
			${TAR} -xvf ${pkgfile}
			pkgdir=${pkgfile%$".tar.gz"}
			;;
		*.tar.gz)
			pkgfile=$(find . -type f -iname "*.tar.gz")
			log "Found package file: ${pkgfile}"
			log "Extracting package ... "
			${TAR} -xvf ${pkgfile}
			pkgdir=${pkgfile%$".tar.gz"}
			;;
		*.zip)
			pkgfile=$(find . -type f -iname "*.zip")
			log "Found package file: ${pkgfile}"
			log "Extracting package ... "
			${UNZIP} ${pkgfile}
			pkgdir=${pkgfile%$".zip"}
			;;
		*)
			err "Couldn't identify package file.\n"\
				"Please report this error on: "\
				"https://github.com/GjjvdBurg/safer_pip"
			;;
	esac
}

check() {
	cd "${TMPDIR}/${pkgdir}"
	# Ask user to check setup.py
	read -r -p $'\e[34mEdit setup.py? [Y/n]\e[0m ' response
	if [ "${response}" = "" ]; then
		response='Y'
	fi
	case $response in
		[yY])
			"${EDITOR:-vi}" setup.py
			;;
		[nN])
			warn "This is really unsafe, see\n${url}"
			;;
	esac
}

install() {
	# Ask user to continue installation
	read -r -p $'\e[34mContinue installing '"$1? [Y/n]"$'\e[0m '\
		response
	if [ "${response}" = "" ]; then
		response='Y'
	fi
	case $response in
		[yY])
			cd ${TMPDIR}
			${PIP} install --user ${pkgfile};;
	esac
}

cleanup() {
	# Cleanup
	log "Cleaning up ..."
	cd ${working_dir}
	rm -rf ${TMPDIR}
	log "Done."
}

run() {
	extract $1
	check
	install $1
}

main() {
	# Download the package with its dependencies
	download

	# First do all the dependencies
	deps=$(ls | grep -v ${pkgname})
	for dep in ${deps}
	do
		run ${dep}
		cd ${TMPDIR}
		rm ${dep}
	done

	# The package we want should now be the only one left.
	fname=$(find . -maxdepth 1 -type f)
	if [ ! "${fname}" = "" ]
	then
		run ${fname}
	fi

	# Run the cleanup
	cleanup
}

main
