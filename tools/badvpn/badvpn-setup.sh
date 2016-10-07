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
        rm -f "${BADVPN_PACKAGE_FILE}" || true
    fi

    # ----- Print exit info -----
    # If exit code is 0
    if [ "${exit_code}" == '0' ]; then
        # Print info
        echo '# ----- BadVPN setup is done -----'

    # If exit code is not 0
    else
        # Print info
        echo '# ----- BadVPN setup is failed -----'
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

# BadVPN package URL
BADVPN_PACKAGE_URL='https://github.com/ambrop72/badvpn/archive/1.999.130.tar.gz'

# BadVPN package file path
[ -z "$BADVPN_PACKAGE_FILE" ] &&
BADVPN_PACKAGE_FILE="${SCRIPT_DIR}/$(basename "$BADVPN_PACKAGE_URL")"

# BadVPN tun2socks program path (only for verifying after setup)
[ -z "${BADVPN_TUN2SOCKS_PROG}" ] &&
BADVPN_TUN2SOCKS_PROG='/usr/local/bin/badvpn-tun2socks'


# ----- Install dependency packages -----
# Print info
echo
echo '# ----- Install dependency packages -----'

# If have `apt-get` command
if command -v 'apt-get' &>/dev/null; then
    # Install packages
    apt-get install -y wget tar libssl-dev libnspr4-dev libnss3-dev pkg-config cmake

# If have `yum` command
elif command -v 'yum' &>/dev/null; then
    # Install packages
    yum install -y wget tar openssl-devel nspr-devel nss-devel pkgconfig

    # Ensure packages are installed
    rpm --query --queryformat '' wget tar openssl-devel nspr-devel nss-devel pkgconfig

    # ----- Special case for CentOS 5 and Oracle Linux 5 -----
    # If is CentOS 5 or Oracle Linux 5
    if grep 'release 5[^0-9]' /etc/centos-release &>/dev/null ||
        grep 'CentOS release 5[^0-9]' /etc/issue &>/dev/null ||
        grep 'release 5[^0-9]' /etc/oracle-release &>/dev/null ||
        grep 'Oracle Linux Server release 5[^0-9]' /etc/issue &>/dev/null ;
    then
        # Install GCC 4.4
        yum install -y gcc44

        # Install G++ 4.4
        yum install -y gcc44-c++

        # Ensure packages are installed
        rpm --query --queryformat '' gcc44 gcc44-c++

        # Add alternative command for `cc`
        update-alternatives --install /usr/local/bin/cc cc /usr/bin/gcc44 1

        # Use alternative command for `cc`
        update-alternatives --set cc /usr/bin/gcc44

        # Add alternative command for `gcc`
        update-alternatives --install /usr/local/bin/gcc gcc /usr/bin/gcc44 1

        # Use alternative command for `gcc`
        update-alternatives --set gcc /usr/bin/gcc44

        # Add alternative command for `g++`
        update-alternatives --install /usr/local/bin/g++ g++ /usr/bin/g++44 1

        # Use alternative command for `g++`
        update-alternatives --set g++ /usr/bin/g++44

        # Clear command cache
        hash -r

        # Install `cmake28`.
        # This requires EPEL repository config.
        yum install -y cmake28

        # If `cmake28` is not installed
        if ! command -v 'cmake28'; then
            # Download EPEL repository config
            wget 'https://dl.fedoraproject.org/pub/epel/epel-release-latest-5.noarch.rpm' -O "${TMP_DIR}/epel-release-latest-5.noarch.rpm"

            # Install EPEL repository config
            rpm -ivh "${TMP_DIR}/epel-release-latest-5.noarch.rpm"

            # Install `cmake28`.
            yum install -y cmake28
        fi

        # Ensure packages are installed
        rpm --query --queryformat '' cmake28

        # Add alternative command for `cmake`
        update-alternatives --install /usr/local/bin/cmake cmake /usr/bin/cmake28 1

        # Use alternative command for `cmake`
        update-alternatives --set cmake /usr/bin/cmake28

        # Clear command cache
        hash -r

    # If is not CentOS 5 or Oracle Linux 5
    else
        # Install `cmake`.
        yum install -y cmake

        # Ensure packages are installed
        rpm --query --queryformat '' cmake
    fi
fi


# ----- Download BadVPN package file -----
# Print info
echo
echo '# ----- Download BadVPN package file -----'

# If have existing BadVPN package file
if [ -r "${BADVPN_PACKAGE_FILE}" ]; then
    # Set is not downloading
    IS_DOWNLOADING=''

    # Print info
    echo "Use existing file: ${BADVPN_PACKAGE_URL}"

# If not have existing BadVPN package file
else
    # Set is downloading
    IS_DOWNLOADING='1'

    # Download BadVPN package file
    wget "${BADVPN_PACKAGE_URL}" -O "${BADVPN_PACKAGE_FILE}"

    # Set is not downloading
    IS_DOWNLOADING=''
fi


# ----- Extract BadVPN package file -----
# Print info
echo
echo '# ----- Extract BadVPN package file -----'

# Extract BadVPN package file
tar xvf "${BADVPN_PACKAGE_FILE}" -C "${TMP_DIR}"

# ----- Install BadVPN -----
# Print info
echo
echo '# ----- Install BadVPN -----'

# Enter extracted BadVPN package directory
cd "${TMP_DIR}"/*

# Create BadVPN build config
cmake .

# Build BadVPN
make

# Install BadVPN
make install


# ----- Locate BadVPN programs -----
# Print info
echo
echo '# ----- Locate BadVPN programs -----'

# Local `badvpn-tun2socks` program
which "${BADVPN_TUN2SOCKS_PROG}"
