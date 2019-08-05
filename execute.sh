#!/bin/bash
set -o pipefail

trap throw_error EXIT

#######################################
# Error handling method which is either exiting the script with exit code 0 (if successful)
# Or with exit code that has been caught by the trap
#######################################
throw_error() {
  # Hint: Do not try to set set +x, set +e or so in this method. Will lead to unexpected results

  ERR_CODE=$?
  if [ "$ERR_CODE" -ne 0 ]; then
    ERR_LOG=$(cat "$LOG_FILE")
    notify-send "Run failed (Exit code: $ERR_CODE)"
    echo "Run failed (Exit code: $ERR_CODE)"
    exit 1
  else
    notify-send "Run successfully completed!"
    echo "Run successfully completed!"
  fi
}

function print_help {
  echo "
This script executes the playbook on the inventory.

Usage:
----------------------------
execute.sh [OPTIONS]

Options:
  -s SKIP_TAGS  : skip certain tags (e.g. spotify)
  -r SKIP_ROLES : skip certain roles (e.g. theme)
  -h            : print this help
"
}

#set -x # show executed commands for easier debugging
set -e # go into trap if a single error occurs

# Logging configuration
NOW=$(date +"%Y%m%d-%H%M%S")
LOG_DIR="./log"
DEBUG_LOG_FILE="${LOG_DIR}/${NOW}_ansible_run_debug.log"
DEBUG_LOG_FILE_LATEST="${LOG_DIR}/latest_debug.log"

# Create if not existing; overwrite if exists
mkdir -p "$LOG_DIR"
echo '' > "$DEBUG_LOG_FILE"
ln -sf "${NOW}_ansible_run_debug.log" "$DEBUG_LOG_FILE_LATEST"
chmod 666 "$DEBUG_LOG_FILE"

# Log output in file and on terminal, see: https://askubuntu.com/questions/811439/bash-set-x-logs-to-file
# exec > $DEBUG_LOG_FILE 2>&1
exec   > >(tee -ia "$DEBUG_LOG_FILE")
exec  2> >(tee -ia "$DEBUG_LOG_FILE" >& 2)
exec 19> "$DEBUG_LOG_FILE"

export BASH_XTRACEFD="19"

# FIXME: temporarily skipping sky and spotify
SKIP_TAGS=""

while getopts ":s:h" opt; do
  case $opt in
    s) SKIP_TAGS=$OPTARG;;
    h) print_help; exit 0;;
    *) error "Invalid option: $opt"; print_help; exit 1;;
  esac
done

# Add more tags with ","
# Example: "sky,spotify"
if [[ -n "$SKIP_TAGS" ]]; then
    echo "[WARNING] Skipping tags: $SKIP_TAGS"
    SKIP_TAGS_ARG="--skip-tags $SKIP_TAGS"
else
    SKIP_TAGS_ARG=""
fi

SETUP_USER_VARS_YML="setup_user_vars.yml"
if [[ ! -e $SETUP_USER_VARS_YML ]]; then
    echo "[ERROR] $SETUP_USER_VARS_YML does not exist in current directory! Please create it. Example:

- setup_user: <username>
- setup_user_email: <email>
- setup_user_full_name: <firstname> <lastname>
- ssh_user: <username>
"
    exit 1
fi
SETUP_USER=$(cat $SETUP_USER_VARS_YML | grep setup_user)
SSH_USER=$(cat $SETUP_USER_VARS_YML | grep ssh_user)

echo "[INFO] Currently, you have the following variables defined for your run:
${SETUP_USER}
${SSH_USER}
If you want to change them, please modify the $SETUP_USER_VARS_YML file."

PLAYBOOK="playbook.yml"
INVENTORY="inventory"

# execute run
sudo ansible-playbook --ask-pass --ask-become-pass $PLAYBOOK -i $INVENTORY -f 10 $SKIP_TAGS_ARG
