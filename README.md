# xap.sh
### XAP - XFCE Actions Patcher
  
Bash script to patch `XFCE Thunar` to be able to use custom actions everywhere.  
By default, most actions are disabled in network folders, Desktop, etc.  
Even the default action `Open terminal here` is disabled in network shares.  
  
XAP works only on **debian-based distros** like `Debian`, `Ubuntu` and `Mint` with `XFCE4`.   
If you are interested on patching a **non debian-based system**, [open a new issue](https://github.com/tavinus/xap.sh/issues/new) and I may try to help.  
  
**`xap.sh` will install apt-get packages and dependencies without confirmation,**   
**it will only ask for confirmation to install the modified thunar package.**  
  
`xap.sh` will ask for confirmation before deleting the work folder or installing the patched `thunar`.  
It is possible to avoid the confirmations by using the execution parameters `-f`, `-k`, `-d`.  
# Disclaimer
*XAP should be safe and has been tested on Ubuntu16+XFCE4, Xubuntu16, Mint17.3 (32bit & 64bit), however...*  
**Thunar is part of the XFCE system, I am not reponsible for any harm caused by this script.  
USE AT YOUR OWN RISK!**
# How To
## Enable source-code repository
This script uses `apt-get build-dep(s)` to prepare the environment.  
In order to use this, you will need to have source-code repositories enabled.  
The easiest way is through `Software Updater → Settings → Ubuntu Software Tab → Source code`.  
Screenshots for Xubuntu16 available at the end of this page.
## Download
**NOTE:** *If you use `git clone` or the [zip](https://github.com/tavinus/xap.sh/archive/master.zip), `xap.sh` will detect the local patch file and use it, instead of downloading it from the internet. This will also remove the dependency on `curl` or `wget` and disable the `--mirror` parameter.*  
#### Clone using `git`
```
git clone https://github.com/tavinus/xap.sh.git
cd xap.sh
./xap.sh --help
```
#### Manual zip download
1. [Download the master zip file](https://github.com/tavinus/xap.sh/archive/master.zip).
2. Extract the zip and open a `terminal` inside the `xap.sh` folder
3. If `xap.sh` is not set as executable, use:
    - `chmod +x ./xap.sh`
4. You should be all set:
    - `./xap.sh --help`
#### Get only `xap.sh` using `wget`
```
wget 'https://raw.githubusercontent.com/tavinus/xap.sh/master/xap.sh' -O ./xap.sh && chmod +x ./xap.sh
./xap.sh --help
```
#### Get only `xap.sh` using `curl`
```
curl -L 'https://raw.githubusercontent.com/tavinus/xap.sh/master/xap.sh' -o ./xap.sh && chmod +x ./xap.sh
./xap.sh --help
```
# Example Runs
#### Just run
```
$ ./xap.sh 

XAP - XFCE Actions Patcher v0.0.1

Checking for sudo executable and privileges, enter your password if needed.
[sudo] password for tavinus: 
Done | Updating package lists
Done | Installing thunar, thunar-data and devscripts
Done | Installing build dependencies for thunar
Done | Preparing work dir: /home/tavinus/xap_patch_temp
Done | Getting thunar source
Done | Downloading Patch
Done | Testing patch with --dry-run
Done | Applying patch
Done | Building deb packages with dpkg-buildpackage
Done | Locating libthunarx deb package

Proceed with package install? (Y/y to install) y
Done | Installing: libthunarx-2-0_1.6.11-0ubuntu0.16.04.1_i386.deb

Success! Please reboot to apply the changes in thunar!

The work directory with sources and deb packages can be removed now.
Dir: /home/tavinus/xap_patch_temp

Do You want to delete the dir? (Y/y to delete) n
Kept working dir!

Ciao
```
#### No prompts, delete temp folder if already exists, keep temp files at the end  
*This is also using the github mirror for the patch `-m`*
```
$ ./xap.sh -m -f -k -d

XAP - XFCE Actions Patcher v0.0.1

Work directory already exists! We need a clean dir to continue.
Dir: /home/tavinus/xap_patch_temp
Working dir removed successfully: /home/tavinus/xap_patch_temp
Checking for sudo executable and privileges, enter your password if needed.
Done | Updating package lists
Done | Installing thunar thunar-data devscripts, we need these up-to-date
Done | Installing build dependencies for thunar
Done | Preparing work dir: /home/tavinus/xap_patch_temp
Done | Getting thunar source
Done | Downloading Patch
Done | Testing patch with --dry-run
Done | Applying patch
Done | Building deb packages with dpkg-buildpackage
Done | Locating libthunarx deb package
Done | Installing: libthunarx-2-0_1.6.11-0ubuntu0.16.04.1_i386.deb

Success! Please reboot to apply the changes in thunar!

Keeping work dir: /home/tavinus/xap_patch_temp
Ciao
```
# Following `log file` during execution
Use this command on another terminal window  
*You need to run this AFTER starting `xap.sh`, obviously*
```
tail -f /tmp/xap_run.log
```
# Options
```
$ ./xap.sh --help

XAP - XFCE Actions Patcher v0.0.1

Usage: xap.sh [-f -d -k]

Options:
  -V, --version           Show program name and version and exits
  -h, --help              Show this help screen and exits
  -m, --mirror            Use my github mirror for the patch, instead of
                          the original xfce bugzilla link.
      --debug             Debug mode, prints to screen instead of logfile.
                          It is usually better to check the logfile:
                          Use: tail -f /tmp/xap_run.log # in another terminal
  -f, --force             Do not ask to confirm system install
  -d, --delete            Do not ask to delete workfolder
                          1. If it already exists when XAP starts
                          2. When XAP finishes execution with success
  -k, --keep              Do not ask to delete work folder at the end
                          Keeps files when XAP finishes with success

Work Folder:
 Location: /home/tavinus/xap_patch_temp
 Use --delete and --keep together to delete at the start of execution
 (if exists) and keep at the end without prompting anything.

Patch File:
 The local patch file will be always used if available, download is disabled.
 If there is no local file, wget or curl will be used to download it.
 Use the "-m" parameter to download the patch from the github mirror.

Apt-get Sources:
 Please make sure you enable source-code repositories in your
 apt-sources. Easiest way is with the Updater GUI.

Examples:
  ./xap.sh             # will ask for confirmations
  ./xap.sh -m          # using github mirror
  ./xap.sh -f          # will install without asking
  ./xap.sh -m -f -k -d # will not ask anything and keep temp files
  ./xap.sh -m -f -d    # will not ask anything and delete temp files
```
# Patch to be applied
 - https://bugzilla.xfce.org/attachment.cgi?id=3482  
 - https://raw.githubusercontent.com/tavinus/xap.sh/master/patches/patch3482.patch

# Related Links
 - [Bug #899624 - ubuntu launchpad](https://bugs.launchpad.net/ubuntu/+source/thunar/+bug/899624?comments=all)
 - [thunar actions only on local drive - ubuntu forum](https://ubuntuforums.org/showthread.php?t=1889890)
 - [thunar actions on shared folders - ubuntu forum](https://ubuntuforums.org/showthread.php?t=2362287)

# Screenshots
## Enabling source-code repositories
This shows how to enable source-code download at Xubuntu16 `Software Updater`.  
  
![xubuntu software update1](https://raw.githubusercontent.com/tavinus/xap.sh/master/screenshots/xubuntu16-01.jpg)  
  
![xubuntu software update2](https://raw.githubusercontent.com/tavinus/xap.sh/master/screenshots/xubuntu16-02.jpg)

# Remove the Patch
To restore the original unpatched Thunar use this command:
```
$ sudo apt-get --reinstall install thunar thunar-data
```
