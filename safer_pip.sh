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

# Define pip command
PIP=pip
# Define unzip command
UNZIP=unzip
# Get package name
pkgname=$1
# Temporary directory
TMPDIR=$(mktemp -d)

working_dir=$(pwd)

cd ${TMPDIR}

echo "Downloading package ... "
${PIP} download --no-binary :all: ${pkgname}

pkgfile=$(find . -iname "${pkgname}*.zip")
echo "Found package file: ${pkgfile}"

echo "Extracting package ... "
${UNZIP} ${pkgfile}
pkgdir=$(basename -s .zip ${pkgfile})
cd "${TMPDIR}/${pkgdir}"

# Ask user to check setup.py
read -r -p "Edit setup.py? [Y/n] " response
if [ "${response}" = "" ]; then
	response='Y'
fi
case $response in
	[yY])
		"${EDITOR:-vi}" setup.py
		;;
	[nN])
		echo -e "This is really unsafe, see\n"\
			"http://incolumitas.com/2016/06/08/typosquatting-package-managers/"
		;;
esac


# Ask user to continue installation
read -r -p "Continue installing ${pkgname}? [Y/n] " response
if [ "${response}" = "" ]; then
	response='Y'
fi
case $response in
	[yY])
		cd ${TMPDIR}
		${PIP} install --user ${pkgfile};;
esac

# Cleanup
echo "Cleaning up ..."
cd ${working_dir}
rm -rf ${TMPDIR}
echo "Done."
