# xap.sh
### XAP - XFCE Actions Patcher
  
Bash script to patch XFCE Thunar to be able to use custom actions everywhere.  
By default, most actions are disabled in network folders, Desktop, ec.  
Even the default action `Open terminal here` is disabled in network shares.  
  
The script will ask for confirmation before doing anything disruptive like deleting the work folder or installing Thunar. It is possible to avoid the confirmations by using the execution flags.
  
## Enable source-code repository
This script uses `apt-get build-dep(s)` to prepare the environment.  
In order to use this, you will need to have source-code repositoies enabled.  
The easiest way is through `Software Updater → Preferences → Enable source-code download`.  
  
## Patch to be applied:
https://bugzilla.xfce.org/attachment.cgi?id=3482
  
## Related Links:

## Help Info
```
$ ./xap.sh -h

XAP - XFCE Actions Patcher v0.0.1

Usage: xap.sh [-f]

Options:
  -V, --version           Show program name and version and exits
  -h, --help              Show this help screen and exits
  -f, --force             Do not ask to confirm system install
  -d, --delete            Delete work folder without prompt if it exists.
  -k, --keep              Keep work folder files at the end of execution,
                          disables prompt.

Use --delete and --keep together to delete at the start of execution
(if exists) and keep work folder at the end without prompting anything.

Notes:
  Please make sure you enable source-code repositories in your
  apt-sources. Easiest way is with the Updater GUI.

Examples:
  ./xap.sh        # will confirm install
  ./xap.sh -f     # will install without asking
```
