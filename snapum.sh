#!/usr/bin/env bash

## Variables ##

# Set first first arg[] as <command>
comm=$1

# Set Version Number
version="v0.4"

## Functions ##

# Help Header
helphead(){
	echo $version
	echo "Usage: snapum <command>"
	echo ""
	echo "Snapum is a script designed to run snapper and yum in conjunction"
	echo "for installing/removing/updating packages using [snapper --command] to"
	echo "auto-create --pre and --post btrfs snapshots."
	echo ""
	echo "Available Commands:"
	echo " help"
	echo " version"
	echo " snapshot"
	echo " search"
	echo " install"
	echo " erase"
	echo " remove"
	echo " upgrade"
	echo " reinstall"
	echo ""
}

# Help Message fn()
helpmsg() {
	echo "Snapum Command info:"
	echo " help:"
	echo "  Shows this help message"
	echo ""
	echo " version:"
	echo "  Shows the version"
	echo ""
	echo " snapshot:"
	echo "  snapshot list"
	echo "   Lists [snapper list] snapshots by number"
	echo "  snapshot delete"
	echo "   Allows for deleting [snapper delete] snapshots"
	echo "  snapshot status"
	echo "   Shows changes between snapshots [snapper status]"
	echo ""
	echo " search:"
	echo "  Searches [yum search] through repos to find packages"
	echo ""
	echo " install:"
	echo "  Installs [yum install] new packages from repos"
	echo ""
	echo " erase:"
	echo "  Uninstalls [yum erase] new packages from repos"
	echo ""
	echo " remove:"
	echo "  Uninstalls [yum remove] new packages from repos"
	echo ""
	echo " upgrade:"
	echo "  Upgrade packages to their newest versions [yum upgrade]"
	echo ""
	echo " reinstall:"
	echo "  Reinstalls [yum reinstall] packages from repos"
	echo ""
}

## Script Start ##

# Force non-error fails to return as error
set -e

# Yum is required. If not installed, Abort
command -v yum >/dev/null 2>&1 || { echo >&2 "'yum' is required, please install it. Aborting."; exit 1; }
# Snapper is required. If not installed, Abort
command -v snapper >/dev/null 2>&1 || { echo >&2 "'snapper' is required, please install it. Aborting."; exit 1; }

# No Arguments
if [ "$#" -eq 0 ]; then
	echo "Error: Requires Arguments"
	echo ""
	helphead
	exit
fi

# Individual Commands
if [ $comm = "help" ]; then
	helphead
	helpmsg

	exit
elif [ $comm = "version" ]; then
	echo snapum $version

	exit
elif [ $comm = "snapshot" ]; then
	# Check for root privileges
	if [ "$EUID" -ne 0 ]; then
		echo "This command needs root privileges."
		echo "Please re-run using root privileges"

		exit 1
	fi

	shift

	if [ $1 = "list" ]; then
		shift
		snapper list $*
	elif [ $1 = "delete" ]; then
		shift
		snapper delete $*
	elif [ $1 = "status" ]; then
		shift
		snapper status $*
	else
		echo "Unsupported snapshot command"
	fi

	exit
elif [[ $comm = "search" ]]; then
	shift
	yum search $*

	exit
elif [ $comm = "install" ]; then
	# Check for root privileges
	if [ "$EUID" -ne 0 ]; then
		echo "This command needs root privileges."
		echo "Please re-run using root privileges"

		exit 1
	fi

	shift

	yumcomm="yum install $*"

	# Must have package names to install anything
	if [ "$#" -eq 0 ]; then
		echo "Requires package name to install"
		exit 1
	fi

	snapper -v create -d "snapum install" --command "$yumcomm"

	exit
elif [ $comm = "erase" ]; then
	# Check for root privileges
	if [ "$EUID" -ne 0 ]; then
		echo "This command needs root privileges."
		echo "Please re-run using root privileges"

		exit 1
	fi

	shift

	yumcomm="yum erase $*"

	# Must have package names to remove anything
	if [ "$#" -eq 0 ]; then
		echo "Requires package name to erase"
		exit 1
	fi

	snapper -v create -d "snapum erase" --command "$yumcomm"

	exit
elif [ $comm = "remove" ]; then
	# Check for root privileges
	if [ "$EUID" -ne 0 ]; then
		echo "This command needs root privileges."
		echo "Please re-run using root privileges"

		exit 1
	fi

	shift

	yumcomm="yum remove $*"

	# Must have package names to remove anything
	if [ "$#" -eq 0 ]; then
		echo "Requires package name to remove"
		exit 1
	fi

	snapper -v create -d "snapum remove" --command "$yumcomm"

	exit
elif [ $comm = "upgrade" ]; then
	# Check for root privileges
	if [ "$EUID" -ne 0 ]; then
		echo "This command needs root privileges."
		echo "Please re-run using root privileges"

		exit 1
	fi
	shift

	yumcomm="yum upgrade $*"

	snapper -v create -d "snapum upgrade" --command "$yumcomm"

	exit
elif [ $comm = "reinstall" ]; then
	# Check for root privileges
	if [ "$EUID" -ne 0 ]; then
		echo "This command needs root privileges."
		echo "Please re-run using root privileges"

		exit 1
	fi
	shift

	yumcomm="yum reinstall $*"

	# Must have package names to reinstall
	if [ "$#" -eq 0 ]; then
		echo "Requires package name to reinstall"
		exit 1
	fi

	exit
else
	echo "Error: Command <$comm> is not a functional command."
	echo ""
	helphead

	exit 1
fi
