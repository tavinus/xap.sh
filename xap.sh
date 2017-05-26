#!/usr/bin/env bash
###############################################
# xap.sh - XFCE Actions Patcher
#
# Gustavo Arnosti Neves
# May / 2017
#
# Tries to solve dependecies and patch XFCE
# Thunar to enable custom actions on remote
# folders, desktop, etc
#
# Try to ask for confirmation before doing
# disruptive things, unless flags are set
#
# Thunar is part of the XFCE system, I am not
# reponsible for any harm caused by this script
# USE AT YOUR OWN RISK!
#
# Patch:
# https://bugzilla.xfce.org/attachment.cgi?id=3482
# https://raw.githubusercontent.com/tavinus/xap.sh/master/patches/patch3482.patch
#
# Where xap.sh lives:
# https://github.com/tavinus/xap.sh


XAP_VERSION='0.0.1'
BANNERSTRING="XAP - XFCE Actions Patcher v$XAP_VERSION"

TRUE=0
FALSE=1

XAP_HOME="$HOME/xap_patch_temp"
XAP_LOGFILE="/tmp/xap_run.log"
XAP_NAME=$(basename $0)

XAP_STATUS=""           # RECEIVES MESSAGES

### Execution FLAGS
FORCE_FLAG=$FALSE       # DO NOT ASK TO INSTALL
CLEAN_WORK_DIR=$FALSE   # DELETE ON EXIT
KEEP_WORK_DIR=$FALSE    # KEEP ON EXIT
DEBUG_MESSAGES=$FALSE   # PRINT EVERYTHING
USE_PATCH_MIRROR=$FALSE # USE GITHUB MIRROR

WGET_BIN="$(which wget 2>/dev/null)"
CURL_BIN="$(which curl 2>/dev/null)"

XFCE_PATCH_URL='https://bugzilla.xfce.org/attachment.cgi?id=3482'
TAVINUS_PATCH_URL='https://raw.githubusercontent.com/tavinus/xap.sh/master/patches/patch3482.patch'
PATCH_URL="$XFCE_PATCH_URL"

# will use local patch if found
LOCAL_PATCH_FILE="$(readlink -f $(dirname $0 2>/dev/null)/patches/patch3482.patch 2>/dev/null)"


#if [[ -r "$LOCAL_PATCH_FILE" ]]; then
#	echo yes
#else
#	echo no
#fi
#exit 0


# Basic Sanity
init_check() {
	if [[ -f "$XAP_LOGFILE" ]]; then
		rm "$XAP_LOGFILE" 2>/dev/null || { echo >&2 "Could not delete logfile: $XAP_LOGFILE" ; exit 2 ; }
	fi
	if ! touch "$XAP_LOGFILE" 2>/dev/null; then
		echo >&2 "Could not create logfile: $XAP_LOGFILE"
		exit 2
	fi
	ps -e | grep -E '^.* xfce4-session$' > /dev/null || initError "No xfce4-session was found running, you would end up installing XFCE4 if you run this."$'\n'"Install xfce4 manually before XAP if you really want to add another desktop."
	[[ ! -x "$WGET_BIN" && ! -x "$CURL_BIN" && ! -r "$LOCAL_PATCH_FILE" ]] && initError "No local patch and no curl or wget installed to download the patch."
	command -v grep >/dev/null 2>&1 || initError "'grep' executable was not found. We need it installed and visible in \$PATH."
	local apt_sources="$(cat /etc/apt/sources.list 2>/dev/null | grep deb-src | grep -v '^#')"
	[[ -z "$apt_sources" ]] && initError "No source-code repositories were active in /etc/apt/sources.list."$'\n'"Please enable source-code repos and try again."
	return $TRUE
}

# Here we do (almost) everything
main() {
	print_banner
	check_workdir_delete "Work directory already exists! We need a clean dir to continue."

	echo "Checking for sudo executable and privileges, enter your password if needed."
	sudo -v || initError "Need sudo to update and install packages, aborting..."

	XAP_STATUS="Updating package lists"
	message_starts
	dRun sudo apt-get update || initError "Could not update list of packages"
	message_ends

	XAP_STATUS="Installing thunar, thunar-data and devscripts"
	message_starts
	dRun sudo apt-get install -y thunar thunar-data || initError "Could not install latest thunar and thunar-data"
	dRun sudo apt-get install -y devscripts
	message_ends

	XAP_STATUS="Installing build dependencies for thunar"
	message_starts
	bdepStatus=1
	dRun sudo apt-get -y build-deps thunar
	bdepStatus=$?
	[ $bdepStatus -eq 0 ] || dRun sudo apt-get -y build-dep thunar 
	bdepStatus=$?
	[ $bdepStatus -eq 0 ] || initError "Could not install build dependencies for Thunar"
	message_ends

	XAP_STATUS="Preparing work dir: $XAP_HOME"
	message_starts
	mkdir "$XAP_HOME" 2>/dev/null || initError "Could not create work folder $XAP_HOME"
	cd "$XAP_HOME" || initError "Could not relocate to work folder $XAP_HOME"
	message_ends

	XAP_STATUS="Getting thunar source"
	message_starts
	dRun apt-get source thunar || initError "Could not get Thunar source!"
	cd thunar-* >/dev/null 2>&1 || initError "Could not relocate to Thunar source folder"
	message_ends

	if [[ -r "$LOCAL_PATCH_FILE" ]]; then
		XAP_STATUS="Using local patch file:"
		message_starts
		dRun cp "$LOCAL_PATCH_FILE" ./ || initError "Could not copy Patch to work folder"
		message_ends
		echo "       $LOCAL_PATCH_FILE"
	else
		XAP_STATUS="Downloading Patch --"
		message_starts
		if [[ -x "$WGET_BIN" ]]; then
			dRun "$WGET_BIN" "$PATCH_URL" -O patch3482.patch || initError "Could not download Patch"
		else
			dRun "$CURL_BIN" -L "$PATCH_URL" -o patch3482.patch || initError "Could not download Patch"
		fi
		message_ends
	fi

	XAP_STATUS="Testing patch with --dry-run"
	command -v patch >/dev/null 2>&1 || initError "'patch' executable was not found. We need it installed and visible in \$PATH."
	message_starts
	dRun patch --dry-run -p1 < patch3482.patch || initError "Patching Test Failed"
	message_ends

	XAP_STATUS="Applying patch"
	message_starts
	dRun patch -p1 < patch3482.patch
	message_ends
	
	XAP_STATUS="Building deb packages with dpkg-buildpackage"
	message_starts
	command -v dpkg-buildpackage >/dev/null 2>&1 || initError "'dpkg-buildpackage' executable was not found. We need it installed and visible in \$PATH."
	dRun dpkg-buildpackage -rfakeroot -uc -b || initError "Building Deb Packages Failed"
	message_ends
	
	XAP_STATUS="Locating libthunarx deb package"
	message_starts
	libthunarx_deb="$(ls ../libthunarx* | grep -v dev)"
	[[ -z "$libthunarx_deb" || ! -f "$libthunarx_deb" ]] && initError "Cloud not locate libthunarx deb package, you may try to install it manually."$'\n'"File string: $libthunarx_deb"
	message_ends

	if ! no_confirm; then
		if ! confirm_user; then
		    echo >&2 $'\nCancelled by user!'
		    exit 3
		fi
	fi

	XAP_STATUS="Installing: $(basename $libthunarx_deb)"
	message_starts
	if dRun sudo dpkg -i "$libthunarx_deb"; then
		message_ends
		echo $'\nSuccess! Please reboot to apply the changes in thunar!\n'
	else
		message_ends
		echo $'\n'"Errors were detected during install, making sure we have a sane environment"
		XAP_STATUS="Checking for dependencies problems"
		message_starts
		dRun sudo apt-get install -f -y || initError "Error when fixing dependency problems"
		message_ends
		echo $'\n'"Seems like you had a broken or not up-to-date thunar install."
		echo "XAP tried to fix the install, but you may need to run:"
		echo "sudo apt-get update && sudo apt-get upgrade"
		echo "and then try running XAP again."
		echo "It is also possible that things are already working fine after the fix."
	fi

	check_workdir_delete "The work directory with sources and deb packages can be removed now." 'KEEPCHECK'

	echo "Ciao"
	exit 0
}


### Parse CLI options
get_options() {
    while :; do
        case "$1" in
            -V|--version|--Version)
                print_banner 'nopadding' ; exit 0 ;;
            -h|--help|--Help)
                print_help ; exit 0 ;;
            --debug)
                DEBUG_MESSAGES=$TRUE ; shift ;;
            -m|--mirror)
                PATCH_URL="$TAVINUS_PATCH_URL"
                shift ;;
            -f|--force)
                FORCE_FLAG=$TRUE ; shift ;;
            -d|--delete)
                CLEAN_WORK_DIR=$TRUE ; shift ;;
            -k|--keep)
                KEEP_WORK_DIR=$TRUE ; shift ;;
            *)  
                check_invalid_opts "$1" ; break ;;
        esac
    done
}

# Since we have no operands, anything but empty is invalid
check_invalid_opts() {
    if [[ ! -z "$1" ]]; then
        print_banner
        echo "Invalid Option: $1"$'\n'
        exit 2
    fi
    return 0    
}

# Returns $TRUE if we are on DEBUG mode, $FALSE otherwise
is_debug() {
	return $DEBUG_MESSAGES
}

# Run something and supress messages if not in DEBUG mode
dRun() {
	[[ -z "$@" ]] && return $FALSE
	if is_debug; then
		"${@}"
		return $?
	else
		echo $'\n[XAP_COMMAND]\n'"${@}"$'\n' >>"$XAP_LOGFILE" 2>&1
		"${@}" >>"$XAP_LOGFILE" 2>&1
		return $?
	fi
	return $FALSE
}

# Returns $TRUE if we should keep working dir without asking
should_keep_workdir() {
	return $KEEP_WORK_DIR
}

# Returns $TRUE if we should delete working dir without asking
force_clean_workdir() {
	return $CLEAN_WORK_DIR
}

# Runa te beginnig and end of script to ask/delete work dir
check_workdir_delete() {
	if [[ "$2" = 'KEEPCHECK' ]] && should_keep_workdir; then
		echo "Keeping work dir: $XAP_HOME"
		return $TRUE
	fi
	if [[ -d "$XAP_HOME" ]]; then
		echo "$1"
		echo "Dir: $XAP_HOME"
		if ! force_clean_workdir; then
			if ! confirm_user "Do You want to delete the dir? (Y/y to delete)"; then
				if [[ "$2" = 'KEEPCHECK' ]]; then
					echo >&2 $'\nKept working dir!\n'
					return $FALSE
				else
					echo >&2 $'\nCancelled by user!\n'
					exit 3
				fi
			fi
		fi
		rm -rf "$XAP_HOME" >/dev/null 2>&1 || initError "Could not delete existing work dir: $XAP_HOME"
		echo "Working dir removed successfully: $XAP_HOME"
	fi
	return $TRUE
}



### Printing functions
print_banner() {
    local str=""
    if [[ "$1" = 'nopadding' ]]; then
        str="$BANNERSTRING"
    else
        str=$'\n'"$BANNERSTRING"$'\n'
    fi
    echo "$str"
}

print_help() {
    print_banner
    echo "Usage: $XAP_NAME [-f]

Options:
  -V, --version           Show program name and version and exits
  -h, --help              Show this help screen and exits
  -m, --mirror            Use my github mirror for the patch, instead of
                          the original xfce bugzilla link.
      --debug             Debug mode, prints to screen instead of logfile.
                          It is usually better to check the logfile:
                          Use: tail -f $XAP_LOGFILE # in another terminal
  -f, --force             Do not ask to confirm system install
  -d, --delete            Do not ask to delete workfolder
                          1. If it already exists when XAP starts
                          2. When XAP finishes execution with success
  -k, --keep              Do not ask to delete work folder at the end
                          Keeps files when XAP finishes with success

WORK FOLDER:
 Location: $XAP_HOME
 Use --delete and --keep together to delete at the start of execution
 (if exists) and keep at the end without prompting anything.

Notes:
  Please make sure you enable source-code repositories in your
  apt-sources. Easiest way is with the Updater GUI.

Examples:
  $0             # will ask for confirmations
  $0 -m          # using github mirror
  $0 -f          # will install without asking
  $0 -m -f -k -d # will not ask anything and keep temp files
  $0 -m -f -d    # will not ask anything and delete temp files
"
}

message_starts() {
    echo -n ".... | $XAP_STATUS"$'\r'
}

message_ends() {
    [[ -z "$XAP_STATUS" ]] && mess="" || mess="$XAP_STATUS"
    echo "Done | $mess"
}

initError() {
	echo >&2 "ERROR: $1"
	exit 2
}


### CLI interaction
no_confirm() {
    return $FORCE_FLAG
}

confirm_user() {
    local conf_msg=$'\nProceed with package install? (Y/y to install) '
    [[ ! -z "$1" ]] && conf_msg=$'\n'"$1 "
    read -p "$conf_msg" -n 1 -r
    if [[ "$REPLY" = Y || "$REPLY" = y ]]; then
	echo ""
        return $TRUE
    fi
    return $FALSE
}

### Start execution
init_check
get_options "$@"
main

exit 20 # should never get here

