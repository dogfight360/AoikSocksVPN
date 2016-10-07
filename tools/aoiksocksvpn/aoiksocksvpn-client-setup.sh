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

    # ----- Print exit info -----
    # If exit code is 0
    if [ "${exit_code}" == '0' ]; then
        # Print info
        echo '# ----- AoikSocksVPN client setup is done -----'

    # If exit code is not 0
    else
        # Print info
        echo '# ----- AoikSocksVPN client setup is failed -----'
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


# ---- AoikSocksVPN client's settings ----
# AoikSocksVPN client's directory owner user and program run-as user
[ -z "$AOIKSOCKSVPN_CLIENT_USER" ] &&
AOIKSOCKSVPN_CLIENT_USER='aoiksocksvpn-client'

# Print info
echo "AOIKSOCKSVPN_CLIENT_USER=${AOIKSOCKSVPN_CLIENT_USER}"

# AoikSocksVPN client's directory
[ -z "$AOIKSOCKSVPN_CLIENT_DIR" ] &&
AOIKSOCKSVPN_CLIENT_DIR='/opt/aoiksocksvpn-client'

# AoikSocksVPN client's program name
[ -z "$AOIKSOCKSVPN_CLIENT_PROG_NAME" ] &&
AOIKSOCKSVPN_CLIENT_PROG_NAME='aoiksocksvpn-client'

# Print info
echo "AOIKSOCKSVPN_CLIENT_PROG_NAME=${AOIKSOCKSVPN_CLIENT_PROG_NAME}"

# AoikSocksVPN client's program path
[ -z "$AOIKSOCKSVPN_CLIENT_PROG" ] &&
AOIKSOCKSVPN_CLIENT_PROG="${AOIKSOCKSVPN_CLIENT_DIR}/${AOIKSOCKSVPN_CLIENT_PROG_NAME}"

# Print info
echo "AOIKSOCKSVPN_CLIENT_PROG=${AOIKSOCKSVPN_CLIENT_PROG}"

# AoikSocksVPN client's program path's symbolic link path
[ -z "$AOIKSOCKSVPN_CLIENT_PROG_SYMLINK" ] &&
AOIKSOCKSVPN_CLIENT_PROG_SYMLINK="/usr/local/bin/${AOIKSOCKSVPN_CLIENT_PROG_NAME}"

# Print info
echo "AOIKSOCKSVPN_CLIENT_PROG_SYMLINK=${AOIKSOCKSVPN_CLIENT_PROG_SYMLINK}"

# AoikSocksVPN client's program PID file
[ -z "$AOIKSOCKSVPN_CLIENT_PROG_PID_PATH" ] &&
AOIKSOCKSVPN_CLIENT_PROG_PID_PATH="${AOIKSOCKSVPN_CLIENT_DIR}/${AOIKSOCKSVPN_CLIENT_PROG_NAME}.pid"

# Print info
echo "AOIKSOCKSVPN_CLIENT_PROG_PID_PATH=${AOIKSOCKSVPN_CLIENT_PROG_PID_PATH}"

# AoikSocksVPN client's program and sub-programs' environment variable PATH value
[ -z "$AOIKSOCKSVPN_CLIENT_PROG_ENV_PATH" ] &&
AOIKSOCKSVPN_CLIENT_PROG_ENV_PATH='/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin'

# Print info
echo "AOIKSOCKSVPN_CLIENT_PROG_ENV_PATH=${AOIKSOCKSVPN_CLIENT_PROG_ENV_PATH}"

# AoikSocksVPN client's SystemD service name
[ -z "$AOIKSOCKSVPN_CLIENT_SYSTEMD_SERVICE_NAME" ] &&
AOIKSOCKSVPN_CLIENT_SYSTEMD_SERVICE_NAME="${AOIKSOCKSVPN_CLIENT_PROG_NAME}"

# Print info
echo "AOIKSOCKSVPN_CLIENT_SYSTEMD_SERVICE_NAME=${AOIKSOCKSVPN_CLIENT_SYSTEMD_SERVICE_NAME}"

# AoikSocksVPN client's SystemD service config path
[ -z "$AOIKSOCKSVPN_CLIENT_SYSTEMD_SERVICE_CONFIG_PATH" ] &&
AOIKSOCKSVPN_CLIENT_SYSTEMD_SERVICE_CONFIG_PATH="/etc/systemd/system/${AOIKSOCKSVPN_CLIENT_SYSTEMD_SERVICE_NAME}.service"

# Print info
echo "AOIKSOCKSVPN_CLIENT_SYSTEMD_SERVICE_CONFIG_PATH=${AOIKSOCKSVPN_CLIENT_SYSTEMD_SERVICE_CONFIG_PATH}"


# ---- AoikSocksVPN client's Shadowsocks client's Kcptun client's settings ----
# Kcptun client program path
[ -z "$KCPTUN_CLIENT_PROG" ] &&
KCPTUN_CLIENT_PROG='/usr/local/bin/kcptun_client'

# Print info
echo "KCPTUN_CLIENT_PROG=${KCPTUN_CLIENT_PROG}"

# AoikSocksVPN server's Shadowsocks server's Kcptun server's host
[ -z "$AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_KCPTUN_SERVER_HOST" ] &&
AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_KCPTUN_SERVER_HOST='127.0.0.1'

# Print info
echo "AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_KCPTUN_SERVER_HOST=${AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_KCPTUN_SERVER_HOST}"

# AoikSocksVPN server's Shadowsocks server's Kcptun server's port
[ -z "$AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_KCPTUN_SERVER_PORT" ] &&
AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_KCPTUN_SERVER_PORT='2090'

# Print info
echo "AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_KCPTUN_SERVER_PORT=${AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_KCPTUN_SERVER_PORT}"

# AoikSocksVPN server's Shadowsocks server's Kcptun server's encryption key
[ -z "$AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_KCPTUN_SERVER_ENCRYPT_KEY" ] &&
AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_KCPTUN_SERVER_ENCRYPT_KEY="${SCRIPT_TIME}"

# Print info
echo "AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_KCPTUN_SERVER_ENCRYPT_KEY=${AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_KCPTUN_SERVER_ENCRYPT_KEY}"

# AoikSocksVPN client's Shadowsocks client's Kcptun client's listening host.
# AoikSocksVPN client's Shadowsocks client connects to this host.
[ -z "$AOIKSOCKSVPN_CLIENT_SHADOWSOCKS_CLIENT_KCPTUN_CLIENT_HOST" ] &&
AOIKSOCKSVPN_CLIENT_SHADOWSOCKS_CLIENT_KCPTUN_CLIENT_HOST='127.0.0.1'

# Print info
echo "AOIKSOCKSVPN_CLIENT_SHADOWSOCKS_CLIENT_KCPTUN_CLIENT_HOST=${AOIKSOCKSVPN_CLIENT_SHADOWSOCKS_CLIENT_KCPTUN_CLIENT_HOST}"

# AoikSocksVPN client's Shadowsocks client's Kcptun client's listening port.
# AoikSocksVPN client's Shadowsocks client connects to this port.
[ -z "$AOIKSOCKSVPN_CLIENT_SHADOWSOCKS_CLIENT_KCPTUN_CLIENT_PORT" ] &&
AOIKSOCKSVPN_CLIENT_SHADOWSOCKS_CLIENT_KCPTUN_CLIENT_PORT='1090'

# Print info
echo "AOIKSOCKSVPN_CLIENT_SHADOWSOCKS_CLIENT_KCPTUN_CLIENT_PORT=${AOIKSOCKSVPN_CLIENT_SHADOWSOCKS_CLIENT_KCPTUN_CLIENT_PORT}"

# AoikSocksVPN client's Shadowsocks client's Kcptun client's program path
[ -z "$AOIKSOCKSVPN_CLIENT_SHADOWSOCKS_CLIENT_KCPTUN_CLIENT_PROG" ] &&
AOIKSOCKSVPN_CLIENT_SHADOWSOCKS_CLIENT_KCPTUN_CLIENT_PROG="${AOIKSOCKSVPN_CLIENT_PROG}-shadowsocks-client-kcptun-client"

# Print info
echo "AOIKSOCKSVPN_CLIENT_SHADOWSOCKS_CLIENT_KCPTUN_CLIENT_PROG=${AOIKSOCKSVPN_CLIENT_SHADOWSOCKS_CLIENT_KCPTUN_CLIENT_PROG}"

# AoikSocksVPN client's Shadowsocks client's Kcptun client's program inner
# command's extra options. Notice some options are required to be consistent
# for both server and client.
[ -z "$AOIKSOCKSVPN_CLIENT_SHADOWSOCKS_CLIENT_KCPTUN_CLIENT_PROG_INNER_CMD_EXTRA_OPTS" ] &&
AOIKSOCKSVPN_CLIENT_SHADOWSOCKS_CLIENT_KCPTUN_CLIENT_PROG_INNER_CMD_EXTRA_OPTS='--mode normal'

# Print info
echo "AOIKSOCKSVPN_CLIENT_SHADOWSOCKS_CLIENT_KCPTUN_CLIENT_PROG_INNER_CMD_EXTRA_OPTS=${AOIKSOCKSVPN_CLIENT_SHADOWSOCKS_CLIENT_KCPTUN_CLIENT_PROG_INNER_CMD_EXTRA_OPTS}"

# AoikSocksVPN client's Shadowsocks client's Kcptun client's program inner
# command
[ -z "$AOIKSOCKSVPN_CLIENT_SHADOWSOCKS_CLIENT_KCPTUN_CLIENT_PROG_INNER_CMD" ] &&
AOIKSOCKSVPN_CLIENT_SHADOWSOCKS_CLIENT_KCPTUN_CLIENT_PROG_INNER_CMD="${KCPTUN_CLIENT_PROG} -l ${AOIKSOCKSVPN_CLIENT_SHADOWSOCKS_CLIENT_KCPTUN_CLIENT_HOST}:${AOIKSOCKSVPN_CLIENT_SHADOWSOCKS_CLIENT_KCPTUN_CLIENT_PORT} -r ${AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_KCPTUN_SERVER_HOST}:${AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_KCPTUN_SERVER_PORT} --key ${AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_KCPTUN_SERVER_ENCRYPT_KEY} ${AOIKSOCKSVPN_CLIENT_SHADOWSOCKS_CLIENT_KCPTUN_CLIENT_PROG_INNER_CMD_EXTRA_OPTS}"

# Print info
echo "AOIKSOCKSVPN_CLIENT_SHADOWSOCKS_CLIENT_KCPTUN_CLIENT_PROG_INNER_CMD=${AOIKSOCKSVPN_CLIENT_SHADOWSOCKS_CLIENT_KCPTUN_CLIENT_PROG_INNER_CMD}"

# AoikSocksVPN client's Shadowsocks client's Kcptun client's program PID file
# path
[ -z "$AOIKSOCKSVPN_CLIENT_SHADOWSOCKS_CLIENT_KCPTUN_CLIENT_PROG_PID_PATH" ] &&
AOIKSOCKSVPN_CLIENT_SHADOWSOCKS_CLIENT_KCPTUN_CLIENT_PROG_PID_PATH="${AOIKSOCKSVPN_CLIENT_SHADOWSOCKS_CLIENT_KCPTUN_CLIENT_PROG}.pid"

# Print info
echo "AOIKSOCKSVPN_CLIENT_SHADOWSOCKS_CLIENT_KCPTUN_CLIENT_PROG_PID_PATH=${AOIKSOCKSVPN_CLIENT_SHADOWSOCKS_CLIENT_KCPTUN_CLIENT_PROG_PID_PATH}"


# ---- AoikSocksVPN client's Shadowsocks client's settings ----
# Shadowsocks client program path
[ -z "$SHADOWSOCKS_CLIENT_PROG" ] &&
SHADOWSOCKS_CLIENT_PROG='/usr/local/bin/ss-local'

# Print info
echo "SHADOWSOCKS_CLIENT_PROG=${SHADOWSOCKS_CLIENT_PROG}"

# AoikSocksVPN server's Shadowsocks server's encryption password
[ -z "$AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_ENCRYPT_PASSWORD" ] &&
AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_ENCRYPT_PASSWORD="${SCRIPT_TIME}"

# Print info
echo "AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_ENCRYPT_PASSWORD=${AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_ENCRYPT_PASSWORD}"

# AoikSocksVPN server's Shadowsocks server's encryption method
[ -z "$AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_ENCRYPT_METHOD" ] &&
AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_ENCRYPT_METHOD='aes-256-cfb'

# Print info
echo "AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_ENCRYPT_METHOD=${AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_ENCRYPT_METHOD}"

# AoikSocksVPN client's Shadowsocks client's listening host.
# AoikSocksVPN client's tun2socks router program connects to this host.
[ -z "$AOIKSOCKSVPN_CLIENT_SHADOWSOCKS_CLIENT_HOST" ] &&
AOIKSOCKSVPN_CLIENT_SHADOWSOCKS_CLIENT_HOST='127.0.0.1'

# Print info
echo "AOIKSOCKSVPN_CLIENT_SHADOWSOCKS_CLIENT_HOST=${AOIKSOCKSVPN_CLIENT_SHADOWSOCKS_CLIENT_HOST}"

# AoikSocksVPN client's Shadowsocks client's listening port.
# AoikSocksVPN client's tun2socks router program connects to this port.
[ -z "$AOIKSOCKSVPN_CLIENT_SHADOWSOCKS_CLIENT_PORT" ] &&
AOIKSOCKSVPN_CLIENT_SHADOWSOCKS_CLIENT_PORT='1080'

# Print info
echo "AOIKSOCKSVPN_CLIENT_SHADOWSOCKS_CLIENT_PORT=${AOIKSOCKSVPN_CLIENT_SHADOWSOCKS_CLIENT_PORT}"

# AoikSocksVPN client's Shadowsocks client's config file path
[ -z "$AOIKSOCKSVPN_CLIENT_SHADOWSOCKS_CLIENT_CONFIG_PATH" ] &&
AOIKSOCKSVPN_CLIENT_SHADOWSOCKS_CLIENT_CONFIG_PATH="${AOIKSOCKSVPN_CLIENT_DIR}/aoiksocksvpn-client-shadowsocks-client-config.json"

# Print info
echo "AOIKSOCKSVPN_CLIENT_SHADOWSOCKS_CLIENT_CONFIG_PATH=${AOIKSOCKSVPN_CLIENT_SHADOWSOCKS_CLIENT_CONFIG_PATH}"

# AoikSocksVPN client's Shadowsocks client's program path
[ -z "$AOIKSOCKSVPN_CLIENT_SHADOWSOCKS_CLIENT_PROG" ] &&
AOIKSOCKSVPN_CLIENT_SHADOWSOCKS_CLIENT_PROG="${AOIKSOCKSVPN_CLIENT_PROG}-shadowsocks-client"

# Print info
echo "AOIKSOCKSVPN_CLIENT_SHADOWSOCKS_CLIENT_PROG=${AOIKSOCKSVPN_CLIENT_SHADOWSOCKS_CLIENT_PROG}"

# AoikSocksVPN client's Shadowsocks client's program inner command
[ -z "$AOIKSOCKSVPN_CLIENT_SHADOWSOCKS_CLIENT_PROG_INNER_CMD" ] &&
AOIKSOCKSVPN_CLIENT_SHADOWSOCKS_CLIENT_PROG_INNER_CMD="${SHADOWSOCKS_CLIENT_PROG} -c '${AOIKSOCKSVPN_CLIENT_SHADOWSOCKS_CLIENT_CONFIG_PATH}'"

# Print info
echo "AOIKSOCKSVPN_CLIENT_SHADOWSOCKS_CLIENT_PROG_INNER_CMD=${AOIKSOCKSVPN_CLIENT_SHADOWSOCKS_CLIENT_PROG_INNER_CMD}"

# AoikSocksVPN client's Shadowsocks client's program PID file path
[ -z "$AOIKSOCKSVPN_CLIENT_SHADOWSOCKS_CLIENT_PROG_PID_PATH" ] &&
AOIKSOCKSVPN_CLIENT_SHADOWSOCKS_CLIENT_PROG_PID_PATH="${AOIKSOCKSVPN_CLIENT_SHADOWSOCKS_CLIENT_PROG}.pid"

# Print info
echo "AOIKSOCKSVPN_CLIENT_SHADOWSOCKS_CLIENT_PROG_PID_PATH=${AOIKSOCKSVPN_CLIENT_SHADOWSOCKS_CLIENT_PROG_PID_PATH}"


# ---- AoikSocksVPN client's tun2socks settings ----
# BadVPN tun2socks program path
[ -z "$BADVPN_TUN2SOCKS_PROG" ] &&
BADVPN_TUN2SOCKS_PROG='/usr/local/bin/badvpn-tun2socks'

# Print info
echo "BADVPN_TUN2SOCKS_PROG=${BADVPN_TUN2SOCKS_PROG}"

# AoikSocksVPN client's tun2socks interface name
[ -z "$AOIKSOCKSVPN_CLIENT_TUN2SOCKS_INTERFACE_NAME" ] &&
AOIKSOCKSVPN_CLIENT_TUN2SOCKS_INTERFACE_NAME='aoikssvpn'

# Print info
echo "AOIKSOCKSVPN_CLIENT_TUN2SOCKS_INTERFACE_NAME=${AOIKSOCKSVPN_CLIENT_TUN2SOCKS_INTERFACE_NAME}"

# AoikSocksVPN client's tun2socks interface host
[ -z "$AOIKSOCKSVPN_CLIENT_TUN2SOCKS_INTERFACE_HOST" ] &&
AOIKSOCKSVPN_CLIENT_TUN2SOCKS_INTERFACE_HOST='10.255.0.2'

# Print info
echo "AOIKSOCKSVPN_CLIENT_TUN2SOCKS_INTERFACE_HOST=${AOIKSOCKSVPN_CLIENT_TUN2SOCKS_INTERFACE_HOST}"

# AoikSocksVPN client's tun2socks interface start program path
[ -z "$AOIKSOCKSVPN_CLIENT_TUN2SOCKS_INTERFACE_START_PROG" ] &&
AOIKSOCKSVPN_CLIENT_TUN2SOCKS_INTERFACE_START_PROG="${AOIKSOCKSVPN_CLIENT_PROG}-tun2socks-interface-start"

# Print info
echo "AOIKSOCKSVPN_CLIENT_TUN2SOCKS_INTERFACE_START_PROG=${AOIKSOCKSVPN_CLIENT_TUN2SOCKS_INTERFACE_START_PROG}"

# AoikSocksVPN client's tun2socks interface stop program path
[ -z "$AOIKSOCKSVPN_CLIENT_TUN2SOCKS_INTERFACE_STOP_PROG" ] &&
AOIKSOCKSVPN_CLIENT_TUN2SOCKS_INTERFACE_STOP_PROG="${AOIKSOCKSVPN_CLIENT_PROG}-tun2socks-interface-stop"

# Print info
echo "AOIKSOCKSVPN_CLIENT_TUN2SOCKS_INTERFACE_STOP_PROG=${AOIKSOCKSVPN_CLIENT_TUN2SOCKS_INTERFACE_STOP_PROG}"

# AoikSocksVPN client's tun2socks router host
[ -z "$AOIKSOCKSVPN_CLIENT_TUN2SOCKS_ROUTER_HOST" ] &&
AOIKSOCKSVPN_CLIENT_TUN2SOCKS_ROUTER_HOST='10.255.0.1'

# Print info
echo "AOIKSOCKSVPN_CLIENT_TUN2SOCKS_ROUTER_HOST=${AOIKSOCKSVPN_CLIENT_TUN2SOCKS_ROUTER_HOST}"

# AoikSocksVPN client's tun2socks router program path
[ -z "$AOIKSOCKSVPN_CLIENT_TUN2SOCKS_ROUTER_PROG" ] &&
AOIKSOCKSVPN_CLIENT_TUN2SOCKS_ROUTER_PROG="${AOIKSOCKSVPN_CLIENT_PROG}-tun2socks-router"

# Print info
echo "AOIKSOCKSVPN_CLIENT_TUN2SOCKS_ROUTER_PROG=${AOIKSOCKSVPN_CLIENT_TUN2SOCKS_ROUTER_PROG}"

# AoikSocksVPN client's tun2socks router program PID file path
[ -z "$AOIKSOCKSVPN_CLIENT_TUN2SOCKS_ROUTER_PROG_PID_PATH" ] &&
AOIKSOCKSVPN_CLIENT_TUN2SOCKS_ROUTER_PROG_PID_PATH="${AOIKSOCKSVPN_CLIENT_TUN2SOCKS_ROUTER_PROG}.pid"

# Print info
echo "AOIKSOCKSVPN_CLIENT_TUN2SOCKS_ROUTER_PROG_PID_PATH=${AOIKSOCKSVPN_CLIENT_TUN2SOCKS_ROUTER_PROG_PID_PATH}"

# AoikSocksVPN client's tun2socks netmask
[ -z "$AOIKSOCKSVPN_CLIENT_TUN2SOCKS_NETMASK" ] &&
AOIKSOCKSVPN_CLIENT_TUN2SOCKS_NETMASK='255.255.255.0'

# Print info
echo "AOIKSOCKSVPN_CLIENT_TUN2SOCKS_NETMASK=${AOIKSOCKSVPN_CLIENT_TUN2SOCKS_NETMASK}"

# Original gateway host used as default gateway when AoikSocksVPN is not
# running
[ -z "$AOIKSOCKSVPN_CLIENT_ORIG_GATEWAY_HOST" ] &&
AOIKSOCKSVPN_CLIENT_ORIG_GATEWAY_HOST='192.168.1.1'

# Print info
echo "AOIKSOCKSVPN_CLIENT_ORIG_GATEWAY_HOST=${AOIKSOCKSVPN_CLIENT_ORIG_GATEWAY_HOST}"

# AoikSocksVPN client's tun2socks routing table start program path
[ -z "$AOIKSOCKSVPN_CLIENT_TUN2SOCKS_ROUTINGTABLE_START_PROG" ] &&
AOIKSOCKSVPN_CLIENT_TUN2SOCKS_ROUTINGTABLE_START_PROG="${AOIKSOCKSVPN_CLIENT_PROG}-tun2socks-routingtable-start"

# Print info
echo "AOIKSOCKSVPN_CLIENT_TUN2SOCKS_ROUTINGTABLE_START_PROG=${AOIKSOCKSVPN_CLIENT_TUN2SOCKS_ROUTINGTABLE_START_PROG}"

# AoikSocksVPN client's tun2socks routing table stop program path
[ -z "$AOIKSOCKSVPN_CLIENT_TUN2SOCKS_ROUTINGTABLE_STOP_PROG" ] &&
AOIKSOCKSVPN_CLIENT_TUN2SOCKS_ROUTINGTABLE_STOP_PROG="${AOIKSOCKSVPN_CLIENT_PROG}-tun2socks-routingtable-stop"

# Print info
echo "AOIKSOCKSVPN_CLIENT_TUN2SOCKS_ROUTINGTABLE_STOP_PROG=${AOIKSOCKSVPN_CLIENT_TUN2SOCKS_ROUTINGTABLE_STOP_PROG}"


# ----- Create AoikSocksVPN client's user -----
# Print info
echo
echo "# ----- Create AoikSocksVPN client's user -----"

# If the user is existing
if id -u "${AOIKSOCKSVPN_CLIENT_USER}" &>/dev/null; then
    # Print info
    echo "User existing: ${AOIKSOCKSVPN_CLIENT_USER}"

# If the user is not existing
else
    # Create user
    useradd "${AOIKSOCKSVPN_CLIENT_USER}" -s /sbin/nologin

    # Print info
    echo "User created: ${AOIKSOCKSVPN_CLIENT_USER}"
fi


# ----- Create AoikSocksVPN client's directory -----
# Print info
echo
echo "# ----- Create AoikSocksVPN client's directory -----"

# Create AoikSocksVPN client's directory
mkdir -pv "${AOIKSOCKSVPN_CLIENT_DIR}"

# Change AoikSocksVPN client's directory's owner
chown "${AOIKSOCKSVPN_CLIENT_USER}:${AOIKSOCKSVPN_CLIENT_USER}" "${AOIKSOCKSVPN_CLIENT_DIR}"

# Change AoikSocksVPN client's directory's modes
chmod 700 "${AOIKSOCKSVPN_CLIENT_DIR}"


# ----- Install `tunctl` for CentOS 5, 6, or Oracle Linux 5, 6 -----
# Print info
echo
echo "# ----- Install \`tunctl\` for CentOS 5, 6, or Oracle Linux 5, 6 -----"

# If is CentOS 5, 6, or Oracle Linux 5, 6
if grep 'release [56][^0-9]' /etc/centos-release &>/dev/null ||
    grep 'CentOS release [56][^0-9]' /etc/issue &>/dev/null ||
    grep 'release [56][^0-9]' /etc/oracle-release &>/dev/null ||
    grep 'Oracle Linux Server release [56][^0-9]' /etc/issue &>/dev/null ;
then
    # Install `tunctl`
    yum install -y tunctl

    # Ensure packages are installed
    rpm --query --queryformat '' tunctl

# If is not CentOS 5, 6, or Oracle Linux 5, 6
else
    # Print info
    echo 'Ignore.'
fi


# ----- Create AoikSocksVPN client's Shadocsocks client's config file -----
# Print info
echo
echo "# ----- Create AoikSocksVPN client's Shadocsocks client's config file -----"

# If have existing config file
if [ -f "${AOIKSOCKSVPN_CLIENT_SHADOWSOCKS_CLIENT_CONFIG_PATH}" ]; then
    # Print info
    echo 'Back up existing config file:'

    # Back up the existing config file
    mv -Tv "${AOIKSOCKSVPN_CLIENT_SHADOWSOCKS_CLIENT_CONFIG_PATH}" "${AOIKSOCKSVPN_CLIENT_SHADOWSOCKS_CLIENT_CONFIG_PATH}.bak.utc${SCRIPT_TIME}"
fi

# Create containing directory if not existing
mkdir -pv "$(dirname "${AOIKSOCKSVPN_CLIENT_SHADOWSOCKS_CLIENT_CONFIG_PATH}")"

# Create AoikSocksVPN client's Shadocsocks client's config file
tee <<ZZZ "${AOIKSOCKSVPN_CLIENT_SHADOWSOCKS_CLIENT_CONFIG_PATH}"
{
    "server": "${AOIKSOCKSVPN_CLIENT_SHADOWSOCKS_CLIENT_KCPTUN_CLIENT_HOST}",
    "server_port": ${AOIKSOCKSVPN_CLIENT_SHADOWSOCKS_CLIENT_KCPTUN_CLIENT_PORT},
    "local_address": "${AOIKSOCKSVPN_CLIENT_SHADOWSOCKS_CLIENT_HOST}",
    "local_port": ${AOIKSOCKSVPN_CLIENT_SHADOWSOCKS_CLIENT_PORT},
    "password": "${AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_ENCRYPT_PASSWORD}",
    "method": "${AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_ENCRYPT_METHOD}",
    "timeout": 600,
    "auth": false
}
ZZZ

# Change the config file's modes
chmod 600 "${AOIKSOCKSVPN_CLIENT_SHADOWSOCKS_CLIENT_CONFIG_PATH}"

# Change the config file's owner
chown "${AOIKSOCKSVPN_CLIENT_USER}:${AOIKSOCKSVPN_CLIENT_USER}" "${AOIKSOCKSVPN_CLIENT_SHADOWSOCKS_CLIENT_CONFIG_PATH}"


# ----- Create AoikSocksVPN client's Shadowsocks client's Kcptun client's program -----
# Print info
echo
echo "# ----- Create AoikSocksVPN client's Shadowsocks client's Kcptun client's program -----"

# Create containing directory if not existing
mkdir -pv "$(dirname "${AOIKSOCKSVPN_CLIENT_SHADOWSOCKS_CLIENT_KCPTUN_CLIENT_PROG}")"

# Create the program file
tee <<ZZZ "${AOIKSOCKSVPN_CLIENT_SHADOWSOCKS_CLIENT_KCPTUN_CLIENT_PROG}"
#!/usr/bin/env bash

# Set quit on error
set -e

# Set PATH
export PATH='${AOIKSOCKSVPN_CLIENT_PROG_ENV_PATH}'

# If the PID file exists,
# and the PID in the PID file exists.
if [ -f '${AOIKSOCKSVPN_CLIENT_SHADOWSOCKS_CLIENT_KCPTUN_CLIENT_PROG_PID_PATH}' ] &&
    ps -p "\$(cat '${AOIKSOCKSVPN_CLIENT_SHADOWSOCKS_CLIENT_KCPTUN_CLIENT_PROG_PID_PATH}')" &>/dev/null ;
then
    # Print info
    echo "Error: AoikSocksVPN client's Shadowsocks client's Kcptun client is running according to PID file: ${AOIKSOCKSVPN_CLIENT_SHADOWSOCKS_CLIENT_KCPTUN_CLIENT_PROG_PID_PATH}"
    echo
    echo 'To stop the running process, run:'
    echo "kill \"\\\$(cat '${AOIKSOCKSVPN_CLIENT_SHADOWSOCKS_CLIENT_KCPTUN_CLIENT_PROG_PID_PATH}')\""
    echo "rm -f '${AOIKSOCKSVPN_CLIENT_SHADOWSOCKS_CLIENT_KCPTUN_CLIENT_PROG_PID_PATH}'"
    echo

    # Exit
    exit 1
fi

# Whether the exit trap function is called before
EXIT_TRAP_IS_CALLED=''

# Create exit trap function
function exit_trap {
    # If the exit trap function is called before
    if [ -n "\${EXIT_TRAP_IS_CALLED}" ]; then
        # Return
        return;

    # If the exit trap function is not called before
    else
        # Set the variable be 1 to ignore next call
        EXIT_TRAP_IS_CALLED='1'
    fi

    # Remove AoikSocksVPN client's Shadowsocks client's Kcptun client's program PID file
    rm -f '${AOIKSOCKSVPN_CLIENT_SHADOWSOCKS_CLIENT_KCPTUN_CLIENT_PROG_PID_PATH}' || true
}

# Hook the exit trap function
trap exit_trap EXIT SIGTERM SIGQUIT SIGABRT SIGINT SIGHUP

# Create PID file's containing directory if not existing
mkdir -pv "\$(dirname '${AOIKSOCKSVPN_CLIENT_SHADOWSOCKS_CLIENT_KCPTUN_CLIENT_PROG_PID_PATH}')"

# Start AoikSocksVPN client's Shadowsocks client's Kcptun client
${AOIKSOCKSVPN_CLIENT_SHADOWSOCKS_CLIENT_KCPTUN_CLIENT_PROG_INNER_CMD} &

# Create PID file
echo "\$!" > '${AOIKSOCKSVPN_CLIENT_SHADOWSOCKS_CLIENT_KCPTUN_CLIENT_PROG_PID_PATH}'

# Wait for AoikSocksVPN client's Shadowsocks client's Kcptun client to quit
wait
ZZZ

# Change the program file's owner
chown "${AOIKSOCKSVPN_CLIENT_USER}:${AOIKSOCKSVPN_CLIENT_USER}" "${AOIKSOCKSVPN_CLIENT_SHADOWSOCKS_CLIENT_KCPTUN_CLIENT_PROG}"

# Change the program file's modes
chmod 700 "${AOIKSOCKSVPN_CLIENT_SHADOWSOCKS_CLIENT_KCPTUN_CLIENT_PROG}"


# ----- Create AoikSocksVPN client's Shadowsocks client's program -----
echo
echo "# ----- Create AoikSocksVPN client's Shadowsocks client's program -----"

# Create containing directory if not existing
mkdir -pv "$(dirname "${AOIKSOCKSVPN_CLIENT_SHADOWSOCKS_CLIENT_PROG}")"

# Create the program file
tee <<ZZZ "${AOIKSOCKSVPN_CLIENT_SHADOWSOCKS_CLIENT_PROG}"
#!/usr/bin/env bash

# Set quit on error
set -e

# Set PATH
export PATH='${AOIKSOCKSVPN_CLIENT_PROG_ENV_PATH}'

# If the PID file exists,
# and the PID in the PID file exists.
if [ -f '${AOIKSOCKSVPN_CLIENT_SHADOWSOCKS_CLIENT_PROG_PID_PATH}' ] &&
    ps -p "\$(cat '${AOIKSOCKSVPN_CLIENT_SHADOWSOCKS_CLIENT_PROG_PID_PATH}')" &>/dev/null ;
then
    # Print info
    echo "Error: AoikSocksVPN client's Shadowsocks client is running according to PID file: ${AOIKSOCKSVPN_CLIENT_SHADOWSOCKS_CLIENT_PROG_PID_PATH}"
    echo
    echo 'To stop the running process, run:'
    echo "kill \"\\\$(cat '${AOIKSOCKSVPN_CLIENT_SHADOWSOCKS_CLIENT_PROG_PID_PATH}')\""
    echo "rm -f '${AOIKSOCKSVPN_CLIENT_SHADOWSOCKS_CLIENT_PROG_PID_PATH}'"
    echo

    # Exit
    exit 1
fi

# Whether the exit trap function is called before
EXIT_TRAP_IS_CALLED=''

# Create exit trap function
function exit_trap {
    # If the exit trap function is called before
    if [ -n "\${EXIT_TRAP_IS_CALLED}" ]; then
        # Return
        return;

    # If the exit trap function is not called before
    else
        # Set the variable be 1 to ignore next call
        EXIT_TRAP_IS_CALLED='1'
    fi

    # Remove AoikSocksVPN client's Shadowsocks client's program PID file
    rm -f '${AOIKSOCKSVPN_CLIENT_SHADOWSOCKS_CLIENT_PROG_PID_PATH}' || true
}

# Hook the exit trap function
trap exit_trap EXIT SIGTERM SIGQUIT SIGABRT SIGINT SIGHUP

# Create PID file's containing directory if not existing
mkdir -pv "\$(dirname '${AOIKSOCKSVPN_CLIENT_SHADOWSOCKS_CLIENT_PROG_PID_PATH}')"

# Start AoikSocksVPN client's Shadowsocks client
${AOIKSOCKSVPN_CLIENT_SHADOWSOCKS_CLIENT_PROG_INNER_CMD} &

# Create PID file
echo "\$!" > '${AOIKSOCKSVPN_CLIENT_SHADOWSOCKS_CLIENT_PROG_PID_PATH}'

# Wait for AoikSocksVPN client's Shadowsocks client to quit
wait
ZZZ

# Change the program file's owner
chown "${AOIKSOCKSVPN_CLIENT_USER}:${AOIKSOCKSVPN_CLIENT_USER}" "${AOIKSOCKSVPN_CLIENT_SHADOWSOCKS_CLIENT_PROG}"

# Change the program file's modes
chmod 700 "${AOIKSOCKSVPN_CLIENT_SHADOWSOCKS_CLIENT_PROG}"


# ----- Create AoikSocksVPN client's tun2socks interface start program -----
echo
echo "# ----- Create AoikSocksVPN client's tun2socks interface start program -----"

# Create containing directory if not existing
mkdir -pv "$(dirname "${AOIKSOCKSVPN_CLIENT_TUN2SOCKS_INTERFACE_START_PROG}")"

# Create the program file
tee <<ZZZ "${AOIKSOCKSVPN_CLIENT_TUN2SOCKS_INTERFACE_START_PROG}"
#!/usr/bin/env bash

# Set quit on error
set -e

# Set PATH
export PATH='${AOIKSOCKSVPN_CLIENT_PROG_ENV_PATH}'

# If is not running as root
if [ "\$(id -u)" != '0' ]; then
    # Print info
    echo 'Error: This script must be run as root.'

    # Exit
    exit 1
fi

# Stop AoikSocksVPN client's tun2socks interface if any
bash ${AOIKSOCKSVPN_CLIENT_TUN2SOCKS_INTERFACE_STOP_PROG}

# If is CentOS 5, 6, or Oracle Linux 5, 6
if grep 'release [56][^0-9]' /etc/centos-release &>/dev/null ||
    grep 'CentOS release [56][^0-9]' /etc/issue &>/dev/null ||
    grep 'release [56][^0-9]' /etc/oracle-release &>/dev/null ||
    grep 'Oracle Linux Server release [56][^0-9]' /etc/issue &>/dev/null ;
then
    # Create AoikSocksVPN client's tun2socks interface using \`tunctl\`
    tunctl -n -t '${AOIKSOCKSVPN_CLIENT_TUN2SOCKS_INTERFACE_NAME}'

# If is not CentOS 5, 6, or Oracle Linux 5, 6
else
    # Create AoikSocksVPN client's tun2socks interface using \`ip tuntap\`
    ip tuntap add dev '${AOIKSOCKSVPN_CLIENT_TUN2SOCKS_INTERFACE_NAME}' mode tun
fi

# Configure AoikSocksVPN client's tun2socks interface
ifconfig '${AOIKSOCKSVPN_CLIENT_TUN2SOCKS_INTERFACE_NAME}' '${AOIKSOCKSVPN_CLIENT_TUN2SOCKS_INTERFACE_HOST}' netmask '${AOIKSOCKSVPN_CLIENT_TUN2SOCKS_NETMASK}'
ZZZ

# Change the program file's owner
chown 'root:root' "${AOIKSOCKSVPN_CLIENT_TUN2SOCKS_INTERFACE_START_PROG}"

# Change the program file's modes
chmod 700 "${AOIKSOCKSVPN_CLIENT_TUN2SOCKS_INTERFACE_START_PROG}"


# ----- Create AoikSocksVPN client's tun2socks interface stop program -----
echo
echo "# ----- Create AoikSocksVPN client's tun2socks interface stop program -----"

# Create containing directory if not existing
mkdir -pv "$(dirname "${AOIKSOCKSVPN_CLIENT_TUN2SOCKS_INTERFACE_STOP_PROG}")"

# Create the program file
tee <<ZZZ "${AOIKSOCKSVPN_CLIENT_TUN2SOCKS_INTERFACE_STOP_PROG}"
#!/usr/bin/env bash

# Set quit on error
set -e

# Set PATH
export PATH='${AOIKSOCKSVPN_CLIENT_PROG_ENV_PATH}'

# If is not running as root
if [ "\$(id -u)" != '0' ]; then
    # Print info
    echo 'Error: This script must be run as root.'

    # Exit
    exit 1
fi

# If AoikSocksVPN client's tun2socks interface is existing
if ifconfig -a | grep '^${AOIKSOCKSVPN_CLIENT_TUN2SOCKS_INTERFACE_NAME}[^a-zA-Z0-9_-]' &>/dev/null ; then
    # Bring down AoikSocksVPN client's tun2socks interface
    ifconfig '${AOIKSOCKSVPN_CLIENT_TUN2SOCKS_INTERFACE_NAME}' down

    # If is CentOS 5, 6, or Oracle Linux 5, 6
    if grep 'release [56][^0-9]' /etc/centos-release &>/dev/null ||
        grep 'CentOS release [56][^0-9]' /etc/issue &>/dev/null ||
        grep 'release [56][^0-9]' /etc/oracle-release &>/dev/null ||
        grep 'Oracle Linux Server release [56][^0-9]' /etc/issue &>/dev/null ;
    then
        # Delete AoikSocksVPN client's tun2socks interface using \`tunctl\`
        tunctl -d '${AOIKSOCKSVPN_CLIENT_TUN2SOCKS_INTERFACE_NAME}' || true

    # If is not CentOS 5, 6, or Oracle Linux 5, 6
    else
        # Delete AoikSocksVPN client's tun2socks interface using \`ip link\`
        ip link del dev '${AOIKSOCKSVPN_CLIENT_TUN2SOCKS_INTERFACE_NAME}' || true
    fi
fi
ZZZ

# Change the program file's owner
chown 'root:root' "${AOIKSOCKSVPN_CLIENT_TUN2SOCKS_INTERFACE_STOP_PROG}"

# Change the program file's modes
chmod 700 "${AOIKSOCKSVPN_CLIENT_TUN2SOCKS_INTERFACE_STOP_PROG}"


# ----- Create AoikSocksVPN client's tun2socks router program -----
echo
echo "# ----- Create AoikSocksVPN client's tun2socks router program -----"

# Create containing directory if not existing
mkdir -pv "$(dirname "${AOIKSOCKSVPN_CLIENT_TUN2SOCKS_ROUTER_PROG}")"

# Create the program file
tee <<ZZZ "${AOIKSOCKSVPN_CLIENT_TUN2SOCKS_ROUTER_PROG}"
#!/usr/bin/env bash

# Set quit on error
set -e

# Set PATH
export PATH='${AOIKSOCKSVPN_CLIENT_PROG_ENV_PATH}'

# If is not running as root
if [ "\$(id -u)" != '0' ]; then
    # Print info
    echo 'Error: This script must be run as root.'

    # Exit
    exit 1
fi

# If the PID file exists,
# and the PID in the PID file exists.
if [ -f '${AOIKSOCKSVPN_CLIENT_TUN2SOCKS_ROUTER_PROG_PID_PATH}' ] &&
    ps -p "\$(cat '${AOIKSOCKSVPN_CLIENT_TUN2SOCKS_ROUTER_PROG_PID_PATH}')" &>/dev/null ;
then
    # Print info
    echo "Error: AoikSocksVPN client's tun2socks router is running according to PID file: ${AOIKSOCKSVPN_CLIENT_TUN2SOCKS_ROUTER_PROG_PID_PATH}"
    echo
    echo 'To stop the running process, run:'
    echo "kill \"\\\$(cat '${AOIKSOCKSVPN_CLIENT_TUN2SOCKS_ROUTER_PROG_PID_PATH}')\""
    echo "rm -f '${AOIKSOCKSVPN_CLIENT_TUN2SOCKS_ROUTER_PROG_PID_PATH}'"
    echo

    # Exit
    exit 1
fi

# Whether the exit trap function is called before
EXIT_TRAP_IS_CALLED=''

# Create exit trap function
function exit_trap {
    # If the exit trap function is called before
    if [ -n "\${EXIT_TRAP_IS_CALLED}" ]; then
        # Return
        return;

    # If the exit trap function is not called before
    else
        # Set the variable be 1 to ignore next call
        EXIT_TRAP_IS_CALLED='1'
    fi

    # Remove AoikSocksVPN client's tun2socks router's program PID file
    rm -f '${AOIKSOCKSVPN_CLIENT_TUN2SOCKS_ROUTER_PROG_PID_PATH}' || true
}

# Hook the exit trap function
trap exit_trap EXIT SIGTERM SIGQUIT SIGABRT SIGINT SIGHUP

# Create PID file's containing directory if not existing
mkdir -pv "\$(dirname '${AOIKSOCKSVPN_CLIENT_TUN2SOCKS_ROUTER_PROG_PID_PATH}')"

# Start AoikSocksVPN client's tun2socks router
'${BADVPN_TUN2SOCKS_PROG}' --tundev '${AOIKSOCKSVPN_CLIENT_TUN2SOCKS_INTERFACE_NAME}' --netif-ipaddr '${AOIKSOCKSVPN_CLIENT_TUN2SOCKS_ROUTER_HOST}' --netif-netmask '${AOIKSOCKSVPN_CLIENT_TUN2SOCKS_NETMASK}' --socks-server-addr '${AOIKSOCKSVPN_CLIENT_SHADOWSOCKS_CLIENT_HOST}:${AOIKSOCKSVPN_CLIENT_SHADOWSOCKS_CLIENT_PORT}' &

# Create PID file
echo "\$!" > '${AOIKSOCKSVPN_CLIENT_TUN2SOCKS_ROUTER_PROG_PID_PATH}'

# Wait for AoikSocksVPN client's tun2socks router to quit
wait
ZZZ

# Change the program file's owner
chown 'root:root' "${AOIKSOCKSVPN_CLIENT_TUN2SOCKS_ROUTER_PROG}"

# Change the program file's modes
chmod 700 "${AOIKSOCKSVPN_CLIENT_TUN2SOCKS_ROUTER_PROG}"


# ----- Create AoikSocksVPN client's tun2socks routing table start program path -----
echo
echo "# ----- Create AoikSocksVPN client's tun2socks routing table start program path -----"

# Create containing directory if not existing
mkdir -pv "$(dirname "${AOIKSOCKSVPN_CLIENT_TUN2SOCKS_ROUTINGTABLE_START_PROG}")"

# Create the program file
tee <<ZZZ "${AOIKSOCKSVPN_CLIENT_TUN2SOCKS_ROUTINGTABLE_START_PROG}"
#!/usr/bin/env bash

# Set quit on error
set -e

# Set PATH
export PATH='${AOIKSOCKSVPN_CLIENT_PROG_ENV_PATH}'

# If is not running as root
if [ "\$(id -u)" != '0' ]; then
    # Print info
    echo 'Error: This script must be run as root.'

    # Exit
    exit 1
fi

# Delete original default gateway route
route del default gw '${AOIKSOCKSVPN_CLIENT_ORIG_GATEWAY_HOST}' 2>/dev/null || true

# Add route for packets headed for VPN server host to go through the original default gateway
route del '${AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_KCPTUN_SERVER_HOST}' gw '${AOIKSOCKSVPN_CLIENT_ORIG_GATEWAY_HOST}' 2>/dev/null || true

route add '${AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_KCPTUN_SERVER_HOST}' gw '${AOIKSOCKSVPN_CLIENT_ORIG_GATEWAY_HOST}' metric 0

# Add route for packets headed for other hosts to go through AoikSocksVPN client's tun2socks router
route del default gw '${AOIKSOCKSVPN_CLIENT_TUN2SOCKS_ROUTER_HOST}' 2>/dev/null || true

route add default gw '${AOIKSOCKSVPN_CLIENT_TUN2SOCKS_ROUTER_HOST}' metric 0

# Print routing table
route -n
ZZZ

# Change the program file's owner
chown 'root:root' "${AOIKSOCKSVPN_CLIENT_TUN2SOCKS_ROUTINGTABLE_START_PROG}"

# Change the program file's modes
chmod 700 "${AOIKSOCKSVPN_CLIENT_TUN2SOCKS_ROUTINGTABLE_START_PROG}"


# ----- Create AoikSocksVPN client's tun2socks routing table stop program path -----
echo
echo "# ----- Create AoikSocksVPN client's tun2socks routing table stop program path -----"

# Create containing directory if not existing
mkdir -pv "$(dirname "${AOIKSOCKSVPN_CLIENT_TUN2SOCKS_ROUTINGTABLE_STOP_PROG}")"

# Create the program file
tee <<ZZZ "${AOIKSOCKSVPN_CLIENT_TUN2SOCKS_ROUTINGTABLE_STOP_PROG}"
#!/usr/bin/env bash

# Set quit on error
set -e

# Set PATH
export PATH='${AOIKSOCKSVPN_CLIENT_PROG_ENV_PATH}'

# If is not running as root
if [ "\$(id -u)" != '0' ]; then
    # Print info
    echo 'Error: This script must be run as root.'

    # Exit
    exit 1
fi

# Delete VPN routes
route del default gw '${AOIKSOCKSVPN_CLIENT_TUN2SOCKS_ROUTER_HOST}' 2>/dev/null || true

route del '${AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_KCPTUN_SERVER_HOST}' gw '${AOIKSOCKSVPN_CLIENT_ORIG_GATEWAY_HOST}' 2>/dev/null || true

# Add back original default gateway route
route add default gw '${AOIKSOCKSVPN_CLIENT_ORIG_GATEWAY_HOST}' metric 0 2>/dev/null || true

# Print routing table
route -n
ZZZ

# Change the program file's owner
chown 'root:root' "${AOIKSOCKSVPN_CLIENT_TUN2SOCKS_ROUTINGTABLE_STOP_PROG}"

# Change the program file's modes
chmod 700 "${AOIKSOCKSVPN_CLIENT_TUN2SOCKS_ROUTINGTABLE_STOP_PROG}"


# ----- Create AoikSocksVPN client's program -----
echo
echo "# ----- Create AoikSocksVPN client's program -----"

# Create containing directory if not existing
mkdir -pv "$(dirname "${AOIKSOCKSVPN_CLIENT_PROG}")"

# Create the program file
tee <<ZZZ "${AOIKSOCKSVPN_CLIENT_PROG}"
#!/usr/bin/env bash

# Set quit on error
set -e

# Set PATH
export PATH='${AOIKSOCKSVPN_CLIENT_PROG_ENV_PATH}'

# If is not running as root
if [ "\$(id -u)" != '0' ]; then
    # Print info
    echo 'Error: This script must be run as root.'

    # Exit
    exit 1
fi

# If the PID file exists
if [ -f "${AOIKSOCKSVPN_CLIENT_PROG_PID_PATH}" ]; then
    # Print info
    echo "Error: AoikSocksVPN client is running according to PID file: ${AOIKSOCKSVPN_CLIENT_PROG_PID_PATH}"
    echo
    echo 'To stop the running process, run:'
    echo "kill \"\\\$(cat '${AOIKSOCKSVPN_CLIENT_PROG_PID_PATH}')\""
    echo "rm -f '${AOIKSOCKSVPN_CLIENT_PROG_PID_PATH}'"
    echo

    # Exit
    exit 1

# If the PID file not exists
else
    # Create containing directory if not existing
    mkdir -pv "\$(dirname "${AOIKSOCKSVPN_CLIENT_PROG_PID_PATH}")"

    # Create PID file
    echo "\$\$" > "${AOIKSOCKSVPN_CLIENT_PROG_PID_PATH}"
fi

# Create exit trap function
function exit_trap {
    # Remove AoikSocksVPN client's PID file
    rm -f "${AOIKSOCKSVPN_CLIENT_PROG_PID_PATH}" || true

    # Stop AoikSocksVPN client's tun2socks routing table
    bash '${AOIKSOCKSVPN_CLIENT_TUN2SOCKS_ROUTINGTABLE_STOP_PROG}' || true

    # Stop AoikSocksVPN client's tun2socks router
    kill "\${AOIKSOCKSVPN_CLIENT_TUN2SOCKS_ROUTER_PROG_PID}" 2>/dev/null || true

    # Stop AoikSocksVPN client's tun2socks interface
    bash '${AOIKSOCKSVPN_CLIENT_TUN2SOCKS_INTERFACE_STOP_PROG}' 2>/dev/null || true

    # Stop AoikSocksVPN client's Shadowsocks client
    kill "\${AOIKSOCKSVPN_CLIENT_SHADOWSOCKS_CLIENT_PROG_PID}" 2>/dev/null || true

    # Stop AoikSocksVPN client's Shadowsocks client's Kcptun client
    kill "\${AOIKSOCKSVPN_CLIENT_SHADOWSOCKS_CLIENT_KCPTUN_CLIENT_PROG_PID}" 2>/dev/null || true
}

# Hook the exit trap function
trap exit_trap EXIT SIGTERM SIGQUIT SIGABRT SIGINT SIGHUP

# Start AoikSocksVPN client's Shadowsocks client's Kcptun client
sudo -u '${AOIKSOCKSVPN_CLIENT_USER}' bash '${AOIKSOCKSVPN_CLIENT_SHADOWSOCKS_CLIENT_KCPTUN_CLIENT_PROG}' &

# Wait for AoikSocksVPN client's Shadowsocks client's Kcptun client's process
# to start and write PID file
sleep 1

# If the PID file not exists,
# or the PID in the PID file not exists.
if ! {
    [ -f '${AOIKSOCKSVPN_CLIENT_SHADOWSOCKS_CLIENT_KCPTUN_CLIENT_PROG_PID_PATH}' ] &&
    AOIKSOCKSVPN_CLIENT_SHADOWSOCKS_CLIENT_KCPTUN_CLIENT_PROG_PID="\$(cat '${AOIKSOCKSVPN_CLIENT_SHADOWSOCKS_CLIENT_KCPTUN_CLIENT_PROG_PID_PATH}')" &&
    ps -p "\${AOIKSOCKSVPN_CLIENT_SHADOWSOCKS_CLIENT_KCPTUN_CLIENT_PROG_PID}" &>/dev/null
} ; then
    # Print info
    echo "Error: Failed starting AoikSocksVPN client's Shadowsocks client's Kcptun client."

    # Exit
    exit 1
fi

# Start AoikSocksVPN client's Shadowsocks client
sudo -u '${AOIKSOCKSVPN_CLIENT_USER}' bash '${AOIKSOCKSVPN_CLIENT_SHADOWSOCKS_CLIENT_PROG}' &

# Wait for AoikSocksVPN client's Shadowsocks client's process to start and
# write PID file
sleep 1

# If the PID file not exists,
# or the PID in the PID file not exists.
if ! {
    [ -f '${AOIKSOCKSVPN_CLIENT_SHADOWSOCKS_CLIENT_PROG_PID_PATH}' ] &&
    AOIKSOCKSVPN_CLIENT_SHADOWSOCKS_CLIENT_PROG_PID="\$(cat '${AOIKSOCKSVPN_CLIENT_SHADOWSOCKS_CLIENT_PROG_PID_PATH}')" &&
    ps -p "\${AOIKSOCKSVPN_CLIENT_SHADOWSOCKS_CLIENT_PROG_PID}" &>/dev/null
} ; then
    # Print info
    echo "Error: Failed starting AoikSocksVPN client's Shadowsocks client."

    # Exit
    exit 1
fi

# Start AoikSocksVPN client's tun2socks interface
bash '${AOIKSOCKSVPN_CLIENT_TUN2SOCKS_INTERFACE_START_PROG}'

# Start AoikSocksVPN client's tun2socks router
bash '${AOIKSOCKSVPN_CLIENT_TUN2SOCKS_ROUTER_PROG}' &

# Wait for AoikSocksVPN client's tun2socks router's process to start and write
# PID file
sleep 1

# If the PID file not exists,
# or the PID in the PID file not exists.
if ! {
    [ -f '${AOIKSOCKSVPN_CLIENT_TUN2SOCKS_ROUTER_PROG_PID_PATH}' ] &&
    AOIKSOCKSVPN_CLIENT_TUN2SOCKS_ROUTER_PROG_PID="\$(cat '${AOIKSOCKSVPN_CLIENT_TUN2SOCKS_ROUTER_PROG_PID_PATH}')" &&
    ps -p "\${AOIKSOCKSVPN_CLIENT_TUN2SOCKS_ROUTER_PROG_PID}" &>/dev/null
} ; then
    # Print info
    echo "Error: Failed starting AoikSocksVPN client's tun2socks router."

    # Exit
    exit 1
fi

# Start AoikSocksVPN client's tun2socks routing table
bash '${AOIKSOCKSVPN_CLIENT_TUN2SOCKS_ROUTINGTABLE_START_PROG}'

# Loop forever
while :;
do
    # For each background process's PID
    for pid in \\
        "\${AOIKSOCKSVPN_CLIENT_SHADOWSOCKS_CLIENT_KCPTUN_CLIENT_PROG_PID}" \\
        "\${AOIKSOCKSVPN_CLIENT_SHADOWSOCKS_CLIENT_PROG_PID}" \\
        "\${AOIKSOCKSVPN_CLIENT_TUN2SOCKS_ROUTER_PROG_PID}" ;
    do
        # If the background process's PID not exists
        if ! ps -p "\${pid}" &>/dev/null; then
            # Exit
            exit 1
        fi
    done

    # Sleep
    sleep 1
done
ZZZ

# Change the program file's owner
chown 'root:root' "${AOIKSOCKSVPN_CLIENT_PROG}"

# Change the program file's modes
chmod 700 "${AOIKSOCKSVPN_CLIENT_PROG}"

# If the symbolic link path is not EQ the program path
if [ "${AOIKSOCKSVPN_CLIENT_PROG_SYMLINK}" != "${AOIKSOCKSVPN_CLIENT_PROG}" ]; then
    # Create containing directory if not existing
    mkdir -pv "$(dirname "${AOIKSOCKSVPN_CLIENT_PROG_SYMLINK}")"

    # Remove symbolic link path if existing
    rm -f "${AOIKSOCKSVPN_CLIENT_PROG_SYMLINK}"

    # Create symbolic link
    ln -sv "${AOIKSOCKSVPN_CLIENT_PROG}" "${AOIKSOCKSVPN_CLIENT_PROG_SYMLINK}"
fi

# ----- Create AoikSocksVPN client's service -----
# Print info
echo
echo "# ----- Create AoikSocksVPN client's service -----"

# If SystemD's `systemctl` command is not found
if ! command -v 'systemctl' &>/dev/null; then
    # Print info
    echo "SystemD's \`systemctl\` command is not found. Ignore."

# If SystemD's `systemctl` command is found
else
    # Print info
    echo
    echo "# ----- Create SystemD service config \`${AOIKSOCKSVPN_CLIENT_SYSTEMD_SERVICE_CONFIG_PATH}\` -----"

    # If have existing config file
    if [ -f "${AOIKSOCKSVPN_CLIENT_SYSTEMD_SERVICE_CONFIG_PATH}" ]; then
        # Print info
        echo 'Back up existing config file:'

        # Back up the existing config file
        mv -Tv "${AOIKSOCKSVPN_CLIENT_SYSTEMD_SERVICE_CONFIG_PATH}" "${AOIKSOCKSVPN_CLIENT_SYSTEMD_SERVICE_CONFIG_PATH}.bak.utc${SCRIPT_TIME}"
    fi

    # Create containing directory if not existing
    mkdir -pv "$(dirname "${AOIKSOCKSVPN_CLIENT_SYSTEMD_SERVICE_CONFIG_PATH}")"

    # Create SystemD service config
    tee <<ZZZ "${AOIKSOCKSVPN_CLIENT_SYSTEMD_SERVICE_CONFIG_PATH}"
[Unit]
After=network.target

[Service]
Type=simple
User=root
ExecStart=${AOIKSOCKSVPN_CLIENT_PROG}
Restart=on-abort

[Install]
WantedBy=multi-user.target
ZZZ

    # Print info
    echo
    echo "# ----- Reload SystemD service configs -----"

    # Reload SystemD service configs
    systemctl daemon-reload
fi


# ----- Usage: Locate AoikSocksVPN client programs -----
# Print info
echo
echo "# ----- Usage: Locate AoikSocksVPN client programs -----"

# Locate programs
which "${AOIKSOCKSVPN_CLIENT_SHADOWSOCKS_CLIENT_KCPTUN_CLIENT_PROG}"

which "${AOIKSOCKSVPN_CLIENT_SHADOWSOCKS_CLIENT_PROG}"

which "${AOIKSOCKSVPN_CLIENT_TUN2SOCKS_INTERFACE_START_PROG}"

which "${AOIKSOCKSVPN_CLIENT_TUN2SOCKS_INTERFACE_STOP_PROG}"

which "${AOIKSOCKSVPN_CLIENT_TUN2SOCKS_ROUTER_PROG}"

which "${AOIKSOCKSVPN_CLIENT_TUN2SOCKS_ROUTINGTABLE_START_PROG}"

which "${AOIKSOCKSVPN_CLIENT_TUN2SOCKS_ROUTINGTABLE_STOP_PROG}"

which "${AOIKSOCKSVPN_CLIENT_PROG}"

# If the symbolic link path is not EQ the program path
if [ "${AOIKSOCKSVPN_CLIENT_PROG_SYMLINK}" != "${AOIKSOCKSVPN_CLIENT_PROG}" ]; then
    # Locate the symbolic link path
    which "${AOIKSOCKSVPN_CLIENT_PROG_SYMLINK}"
fi


# ----- Usage: Start AoikSocksVPN client program -----
# Print info
echo
cat <<ZZZ
# ----- Usage: Start AoikSocksVPN client program -----
sudo '${AOIKSOCKSVPN_CLIENT_PROG_SYMLINK}'
ZZZ


# ----- Usage: Start AoikSocksVPN client service -----
# Print info
echo
echo "# ----- Usage: Start AoikSocksVPN client service -----"

# If SystemD's `systemctl` command is not found
if ! command -v 'systemctl' &>/dev/null; then
    # Print info
    echo "SystemD's \`systemctl\` command is not found. Ignore."

# If SystemD's `systemctl` command is found
else
    # Print info
    cat <<ZZZ
# Start AoikSocksVPN client service
systemctl start '${AOIKSOCKSVPN_CLIENT_SYSTEMD_SERVICE_NAME}.service'

# Stop AoikSocksVPN client service
systemctl stop '${AOIKSOCKSVPN_CLIENT_SYSTEMD_SERVICE_NAME}.service'

# Check AoikSocksVPN client service status
systemctl status '${AOIKSOCKSVPN_CLIENT_SYSTEMD_SERVICE_NAME}.service'

# Check service error log
journalctl -ex
ZZZ
fi


# ----- Usage: Configure Sudo -----
# Print info
echo
cat <<ZZZ
# ----- Usage: Configure Sudo -----
Running AoikSocksVPN client service requires adjusting Sudo config.

Run:
\`\`\`
visudo
\`\`\`

Edit:
\`\`\`
# ----- Disable \`requiretty\` option -----
# Defaults requiretty

# ----- Allow root to run any commands -----
root ALL=(ALL) ALL
\`\`\`
ZZZ


# ----- Usage: Check whether the VPN works -----
# Print info
echo
cat <<ZZZ
# ----- Usage: Check whether the VPN works -----
# Notice only TCP packets are routed by the VPN.
# Pinging any remote host will not work, except for AoikSocksVPN server's Shadowsocks server's Kcptun server's host.
curl -v "https://github.com/"

# If the VPN not works, below are methods for checking error causes.

# Check whether AoikSocksVPN server's Shadowsocks server's Kcptun server's host can be pinged
ping "${AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_KCPTUN_SERVER_HOST}"

# Check whether AoikSocksVPN client's Shadowsocks client's listening port works
curl -v --socks5 "${AOIKSOCKSVPN_CLIENT_SHADOWSOCKS_CLIENT_HOST}:${AOIKSOCKSVPN_CLIENT_SHADOWSOCKS_CLIENT_PORT}" "https://github.com/"
# or
curl -v --socks5-hostname "${AOIKSOCKSVPN_CLIENT_SHADOWSOCKS_CLIENT_HOST}:${AOIKSOCKSVPN_CLIENT_SHADOWSOCKS_CLIENT_PORT}" "https://github.com/"

# Check whether AoikSocksVPN client's tun2socks interface can be pinged ----
ping "${AOIKSOCKSVPN_CLIENT_TUN2SOCKS_INTERFACE_HOST}"

# Check whether AoikSocksVPN client's tun2socks router can be pinged
ping "${AOIKSOCKSVPN_CLIENT_TUN2SOCKS_ROUTER_HOST}"

# Check whether AoikSocksVPN client's tun2socks routing table is configured
route -n

# Check other configs
# Sudo config.
# SELinux config.
ZZZ
