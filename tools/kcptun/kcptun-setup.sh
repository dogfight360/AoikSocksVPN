#!/usr/bin/env bash


# ----- Quit on error -----
# Set quit on error
set -e


# ----- Ensure running as root -----
# If is not running as root
if [ "$(id -u)" != '0' ]; then
    # Print info
    echo 'Error: This script must be run as root.'

    # Exit
    exit 1
fi


# ----- Create temporary directory -----
# Print info
echo
echo '# ----- Create temporary directory -----'

# Get current time
SCRIPT_TIME="$(date -u +'%Y%m%d%H%M%S%N')"

# Store old working directory
OLD_CWD="$(pwd)"

# Get this script's directoy path
SCRIPT_DIR="$(cd "$(dirname "$0")"; pwd)"

# Get temporary directory path
TMP_DIR="${SCRIPT_DIR}/.tmp.utc${SCRIPT_TIME}"

# Create temporary directory
mkdir -v "${TMP_DIR}"


# ----- Create exit trap function -----
# Whether the exit trap function is called before
EXIT_TRAP_IS_CALLED=''

# Create exit trap function
function exit_trap {
    # Get exit code
    exit_code="$?"

    # ----- Avoid duplicate call -----
    # If the exit trap function is called before
    if [ -n "${EXIT_TRAP_IS_CALLED}" ]; then
        # Return
        return

    # If the exit trap function is not called before
    else
        # Set the variable be 1 to ignore next call
        EXIT_TRAP_IS_CALLED='1'
    fi

    # ----- Remove temporary directory -----
    # Print info
    echo
    echo '# ----- Remove temporary directory -----'

    # Remove temporary directory
    [ -d "${TMP_DIR}" ] && rm -rf "${TMP_DIR}"

    # Print newline
    echo

    # ----- Remove interrupted download file -----
    # If download is interrupted
    if [ "${IS_DOWNLOADING}" == '1' ] ; then
        # Remove interrupted download file
        rm -f "${KCPTUN_PACKAGE_FILE}" || true
    fi

    # ----- Print exit info -----
    # If exit code is 0
    if [ "${exit_code}" == '0' ]; then
        # Print info
        echo '# ----- Kcptun setup is done -----'

    # If exit code is not 0
    else
        # Print info
        echo '# ----- Kcptun setup is failed -----'
        echo "Exit code: $exit_code"
    fi

    # Print newline
    echo

    # ----- Restore old working directory -----
    # Restore old working directory
    [ -d "${OLD_CWD}" ] && cd "${OLD_CWD}"
}

# Hook the exit trap function
trap exit_trap EXIT SIGTERM SIGQUIT SIGABRT SIGINT SIGHUP


# ----- Validate settings -----
# Print info
echo
echo '# ----- Validate settings -----'

# Kcptun package URL
[ -z "$KCPTUN_PACKAGE_URL" ] &&
KCPTUN_PACKAGE_URL='https://github.com/xtaci/kcptun/releases/download/v20160922/kcptun-linux-amd64-20160922.tar.gz'

# Print info
echo "KCPTUN_PACKAGE_URL=${KCPTUN_PACKAGE_URL}"

# Kcptun package file path
[ -z "$KCPTUN_PACKAGE_FILE" ] &&
KCPTUN_PACKAGE_FILE="${SCRIPT_DIR}/$(basename "$KCPTUN_PACKAGE_URL")"

# Print info
echo "KCPTUN_PACKAGE_FILE=${KCPTUN_PACKAGE_FILE}"

# Kcptun server program path
[ -z "${KCPTUN_SERVER_PROG}" ] &&
KCPTUN_SERVER_PROG='/usr/local/bin/kcptun_server'

# Print info
echo "KCPTUN_SERVER_PROG=${KCPTUN_SERVER_PROG}"

# Kcptun client program path
[ -z "${KCPTUN_CLIENT_PROG}" ] &&
KCPTUN_CLIENT_PROG='/usr/local/bin/kcptun_client'

# Print info
echo "KCPTUN_CLIENT_PROG=${KCPTUN_CLIENT_PROG}"


# ----- Install dependency packages -----
# Print info
echo
echo '# ----- Install dependency packages -----'

# If have `apt-get` command
if command -v 'apt-get' &>/dev/null; then
    # Install packages
    apt-get install -y wget tar

# If have `yum` command
elif command -v 'yum' &>/dev/null; then
    # Install packages
    yum install -y wget tar

    # Ensure packages are installed
    rpm --query --queryformat '' wget tar
fi


# ----- Download Kcptun package file -----
# Print info
echo
echo '# ----- Download Kcptun package file -----'

# If have existing Kcptun package file
if [ -r "${KCPTUN_PACKAGE_FILE}" ]; then
    # Set is not downloading
    IS_DOWNLOADING=''

    # Print info
    echo "Use existing file: ${KCPTUN_PACKAGE_FILE}"

# If not have existing Kcptun package file
else
    # Set is downloading
    IS_DOWNLOADING='1'

    # Download Kcptun package file
    wget "${KCPTUN_PACKAGE_URL}" -O "${KCPTUN_PACKAGE_FILE}"

    # Set is not downloading
    IS_DOWNLOADING=''
fi


# ----- Extract Kcptun package file -----
# Print info
echo
echo '# ----- Extract Kcptun package file -----'

# Extract Kcptun package file
tar xvf "${KCPTUN_PACKAGE_FILE}" -C "${TMP_DIR}"

# ----- Install Kcptun -----
# Print info
echo
echo '# ----- Install Kcptun -----'

# Create containing directory if not existing
mkdir -pv "$(dirname "${KCPTUN_SERVER_PROG}")"

# Install Kcptun server program
mv -Tv "${TMP_DIR}/server_linux_amd64" "${KCPTUN_SERVER_PROG}"

# Change Kcptun server program's modes
chmod 755 "${KCPTUN_SERVER_PROG}"

# Create containing directory if not existing
mkdir -pv "$(dirname "${KCPTUN_CLIENT_PROG}")"

# Install Kcptun client program
mv -Tv "${TMP_DIR}/client_linux_amd64" "${KCPTUN_CLIENT_PROG}"

# Change Kcptun client program's modes
chmod 755 "${KCPTUN_CLIENT_PROG}"


# ----- Locate Kcptun programs -----
# Print info
echo
echo '# ----- Locate Kcptun programs -----'

# Local Kcptun server program
which "${KCPTUN_SERVER_PROG}"

# Local Kcptun client program
which "${KCPTUN_CLIENT_PROG}"
