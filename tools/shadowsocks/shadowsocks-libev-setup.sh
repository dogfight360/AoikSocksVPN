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
        rm -f "${SHADOWSOCKS_PACKAGE_FILE}" || true
    fi

    # ----- Print exit info -----
    # If exit code is 0
    if [ "${exit_code}" == '0' ]; then
        # Print info
        echo '# ----- Shadowsocks setup is done -----'

    # If exit code is not 0
    else
        # Print info
        echo '# ----- Shadowsocks setup is failed -----'
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

# Shadowsocks package URL
[ -z "$SHADOWSOCKS_PACKAGE_URL" ] &&
SHADOWSOCKS_PACKAGE_URL='https://github.com/shadowsocks/shadowsocks-libev/archive/v2.5.3.tar.gz'

# Print info
echo "SHADOWSOCKS_PACKAGE_URL=${SHADOWSOCKS_PACKAGE_URL}"

# Shadowsocks package file path
[ -z "$SHADOWSOCKS_PACKAGE_FILE" ] &&
SHADOWSOCKS_PACKAGE_FILE="${SCRIPT_DIR}/$(basename "$SHADOWSOCKS_PACKAGE_URL")"

# Print info
echo "SHADOWSOCKS_PACKAGE_FILE=${SHADOWSOCKS_PACKAGE_FILE}"

# Shadowsocks server program path (only for verifying after setup)
[ -z "${SHADOWSOCKS_SERVER_PROG}" ] &&
SHADOWSOCKS_SERVER_PROG='/usr/local/bin/ss-server'

# Print info
echo "SHADOWSOCKS_SERVER_PROG=${SHADOWSOCKS_SERVER_PROG}"

# Shadowsocks client program path (only for verifying after setup)
[ -z "${SHADOWSOCKS_CLIENT_PROG}" ] &&
SHADOWSOCKS_CLIENT_PROG='/usr/local/bin/ss-local'

# Print info
echo "SHADOWSOCKS_CLIENT_PROG=${SHADOWSOCKS_CLIENT_PROG}"


# ----- Install dependency packages -----
# Print info
echo
echo '# ----- Install dependency packages -----'

# If have `apt-get` command
if command -v 'apt-get' &>/dev/null; then
    # Install packages
    apt-get install -y --no-install-recommends wget build-essential autoconf libtool libssl-dev asciidoc xmlto libpcre3-dev

# If have `yum` command
elif command -v 'yum' &>/dev/null; then
    # Install packages
    yum install -y wget gcc autoconf libtool automake make zlib-devel openssl-devel xmlto pcre-devel

    # Ensure packages are installed
    rpm --query --queryformat '' wget gcc autoconf libtool automake make zlib-devel openssl-devel xmlto pcre-devel

    # ----- Install `asciidoc` -----
    # If is Oracle Linux 5
    if grep 'release 5[^0-9]' /etc/oracle-release &>/dev/null ||
        grep 'Oracle Linux Server release 5[^0-9]' /etc/issue &>/dev/null ;
    then
        # Do nothing.
        # Oracle Linux 5 has no repository containing `asciidoc`
        true

    # If is Oracle Linux 6
    elif grep 'release 6[^0-9]' /etc/oracle-release &>/dev/null ||
        grep 'Oracle Linux Server release 6[^0-9]' /etc/issue &>/dev/null ;
    then
        # Enable the repository containing `asciidoc`
        yum-config-manager --enable ol6_optional_latest

        # Install `asciidoc`
        yum install -y asciidoc

        # Ensure packages are installed
        rpm --query --queryformat '' asciidoc

    # If is Oracle Linux 7
    elif grep 'release 7[^0-9]' /etc/oracle-release &>/dev/null ||
        grep 'Oracle Linux Server release 7[^0-9]' /etc/issue &>/dev/null ;
    then
        # Enable the repository containing `asciidoc`
        yum-config-manager --enable ol7_optional_latest

        # Install `asciidoc`
        yum install -y asciidoc

        # Ensure packages are installed
        rpm --query --queryformat '' asciidoc

    # If is none of above
    else
        # Install `asciidoc`
        yum install -y asciidoc

        # Ensure packages are installed
        rpm --query --queryformat '' asciidoc
    fi
fi


# ----- Download Shadowsocks package file -----
# Print info
echo
echo '# ----- Download Shadowsocks package file -----'

# If have existing Shadowsocks package file
if [ -r "${SHADOWSOCKS_PACKAGE_FILE}" ]; then
    # Set is not downloading
    IS_DOWNLOADING=''

    # Print info
    echo "Use existing file: ${SHADOWSOCKS_PACKAGE_FILE}"

# If not have existing Shadowsocks package file
else
    # Set is downloading
    IS_DOWNLOADING='1'

    # Download Shadowsocks package file
    wget "${SHADOWSOCKS_PACKAGE_URL}" -O "${SHADOWSOCKS_PACKAGE_FILE}"

    # Set is not downloading
    IS_DOWNLOADING=''
fi


# ----- Extract Shadowsocks package file -----
# Print info
echo
echo '# ----- Extract Shadowsocks package file -----'

# Extract Shadowsocks package file
tar xvf "${SHADOWSOCKS_PACKAGE_FILE}" -C "${TMP_DIR}"


# ----- Install Shadowsocks -----
# Print info
echo
echo '# ----- Install Shadowsocks -----'

# Enter extracted Shadowsocks package directory
cd "${TMP_DIR}"/*

# Configure build
./configure

# If is Oracle Linux 5
if grep 'release 5[^0-9]' /etc/oracle-release &>/dev/null ||
    grep 'Oracle Linux Server release 5[^0-9]' /etc/issue &>/dev/null ;
then
    # Rename the `doc` directory.
    # This aims to avoid building doc using `asciidoc`.
    # Oracle Linux 5 has no repository containing `asciidoc`.
    mv doc doc.bak

    # Build Shadowsocks
    make || true

    # Install Shadowsocks
    make install || true

# If is not Oracle Linux 5
else
    # Build Shadowsocks
    make

    # Install Shadowsocks
    make install
fi


# ----- Locate Shadowsocks programs -----
# Print info
echo
echo '# ----- Locate Shadowsocks programs -----'

# Local Shadowsocks server program
which "${SHADOWSOCKS_SERVER_PROG}"

# Local Shadowsocks client program
which "${SHADOWSOCKS_CLIENT_PROG}"
