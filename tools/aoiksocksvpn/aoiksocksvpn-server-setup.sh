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
        echo '# ----- AoikSocksVPN server setup is done -----'

    # If exit code is not 0
    else
        # Print info
        echo '# ----- AoikSocksVPN server setup is failed -----'
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


# ---- AoikSocksVPN server's settings ----
# AoikSocksVPN server's directory owner user and program run-as user
[ -z "$AOIKSOCKSVPN_SERVER_USER" ] &&
AOIKSOCKSVPN_SERVER_USER='aoiksocksvpn-server'

# Print info
echo "AOIKSOCKSVPN_SERVER_USER=${AOIKSOCKSVPN_SERVER_USER}"

# AoikSocksVPN server's directory
[ -z "$AOIKSOCKSVPN_SERVER_DIR" ] &&
AOIKSOCKSVPN_SERVER_DIR='/opt/aoiksocksvpn-server'

# AoikSocksVPN server's program name
[ -z "$AOIKSOCKSVPN_SERVER_PROG_NAME" ] &&
AOIKSOCKSVPN_SERVER_PROG_NAME='aoiksocksvpn-server'

# Print info
echo "AOIKSOCKSVPN_SERVER_PROG_NAME=${AOIKSOCKSVPN_SERVER_PROG_NAME}"

# AoikSocksVPN server's program path
[ -z "$AOIKSOCKSVPN_SERVER_PROG" ] &&
AOIKSOCKSVPN_SERVER_PROG="${AOIKSOCKSVPN_SERVER_DIR}/${AOIKSOCKSVPN_SERVER_PROG_NAME}"

# Print info
echo "AOIKSOCKSVPN_SERVER_PROG=${AOIKSOCKSVPN_SERVER_PROG}"

# AoikSocksVPN server's program path's symbolic link path
[ -z "$AOIKSOCKSVPN_SERVER_PROG_SYMLINK" ] &&
AOIKSOCKSVPN_SERVER_PROG_SYMLINK="/usr/local/bin/${AOIKSOCKSVPN_SERVER_PROG_NAME}"

# Print info
echo "AOIKSOCKSVPN_SERVER_PROG_SYMLINK=${AOIKSOCKSVPN_SERVER_PROG_SYMLINK}"

# AoikSocksVPN server's program PID file
[ -z "$AOIKSOCKSVPN_SERVER_PROG_PID_PATH" ] &&
AOIKSOCKSVPN_SERVER_PROG_PID_PATH="${AOIKSOCKSVPN_SERVER_DIR}/${AOIKSOCKSVPN_SERVER_PROG_NAME}.pid"

# Print info
echo "AOIKSOCKSVPN_SERVER_PROG_PID_PATH=${AOIKSOCKSVPN_SERVER_PROG_PID_PATH}"

# AoikSocksVPN server's program and sub-programs' environment variable PATH value
[ -z "$AOIKSOCKSVPN_SERVER_PROG_ENV_PATH" ] &&
AOIKSOCKSVPN_SERVER_PROG_ENV_PATH='/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin'

# Print info
echo "AOIKSOCKSVPN_SERVER_PROG_ENV_PATH=${AOIKSOCKSVPN_SERVER_PROG_ENV_PATH}"

# AoikSocksVPN server's SystemD service name
[ -z "$AOIKSOCKSVPN_SERVER_SYSTEMD_SERVICE_NAME" ] &&
AOIKSOCKSVPN_SERVER_SYSTEMD_SERVICE_NAME="${AOIKSOCKSVPN_SERVER_PROG_NAME}"

# Print info
echo "AOIKSOCKSVPN_SERVER_SYSTEMD_SERVICE_NAME=${AOIKSOCKSVPN_SERVER_SYSTEMD_SERVICE_NAME}"

# AoikSocksVPN server's SystemD service config path
[ -z "$AOIKSOCKSVPN_SERVER_SYSTEMD_SERVICE_CONFIG_PATH" ] &&
AOIKSOCKSVPN_SERVER_SYSTEMD_SERVICE_CONFIG_PATH="/etc/systemd/system/${AOIKSOCKSVPN_SERVER_SYSTEMD_SERVICE_NAME}.service"

# Print info
echo "AOIKSOCKSVPN_SERVER_SYSTEMD_SERVICE_CONFIG_PATH=${AOIKSOCKSVPN_SERVER_SYSTEMD_SERVICE_CONFIG_PATH}"


# ---- AoikSocksVPN server's Shadowsocks server's settings ----
# Shadowsocks server program path
[ -z "$SHADOWSOCKS_SERVER_PROG" ] &&
SHADOWSOCKS_SERVER_PROG='/usr/local/bin/ss-server'

# Print info
echo "SHADOWSOCKS_SERVER_PROG=${SHADOWSOCKS_SERVER_PROG}"

# AoikSocksVPN server's Shadowsocks server's host
[ -z "$AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_HOST" ] &&
AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_HOST='127.0.0.1'

# Print info
echo "AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_HOST=${AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_HOST}"

# AoikSocksVPN server's Shadowsocks server's port
[ -z "$AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_PORT" ] &&
AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_PORT='2080'

# Print info
echo "AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_PORT=${AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_PORT}"

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

# AoikSocksVPN server's Shadowsocks server's nameserver
[ -z "$AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_NAMESERVER" ] &&
AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_NAMESERVER='8.8.8.8'

# Print info
echo "AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_NAMESERVER=${AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_NAMESERVER}"

# AoikSocksVPN server's Shadowsocks server's config file path
[ -z "$AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_CONFIG_PATH" ] &&
AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_CONFIG_PATH="${AOIKSOCKSVPN_SERVER_DIR}/aoiksocksvpn-server-shadowsocks-server-config.json"

# Print info
echo "AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_CONFIG_PATH=${AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_CONFIG_PATH}"

# AoikSocksVPN server's Shadowsocks server's program path
[ -z "$AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_PROG" ] &&
AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_PROG="${AOIKSOCKSVPN_SERVER_PROG}-shadowsocks-server"

# Print info
echo "AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_PROG=${AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_PROG}"

# AoikSocksVPN server's Shadowsocks server's program inner command
[ -z "$AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_PROG_INNER_CMD" ] &&
AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_PROG_INNER_CMD="${SHADOWSOCKS_SERVER_PROG} -c '${AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_CONFIG_PATH}'"

# Print info
echo "AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_PROG_INNER_CMD=${AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_PROG_INNER_CMD}"

# AoikSocksVPN server's Shadowsocks server's program PID file
# path
[ -z "$AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_PROG_PID_PATH" ] &&
AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_PROG_PID_PATH="${AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_PROG}.pid"

# Print info
echo "AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_PROG_PID_PATH=${AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_PROG_PID_PATH}"


# ---- AoikSocksVPN server's Shadowsocks server's Kcptun server's settings ----
# Kcptun server's program path
[ -z "$KCPTUN_SERVER_PROG" ] &&
KCPTUN_SERVER_PROG='/usr/local/bin/kcptun_server'

# Print info
echo "KCPTUN_SERVER_PROG=${KCPTUN_SERVER_PROG}"

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

# AoikSocksVPN server's Shadowsocks server's Kcptun server's program path
[ -z "$AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_KCPTUN_SERVER_PROG" ] &&
AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_KCPTUN_SERVER_PROG="${AOIKSOCKSVPN_SERVER_PROG}-shadowsocks-server-kcptun-server"

# Print info
echo "AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_KCPTUN_SERVER_PROG=${AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_KCPTUN_SERVER_PROG}"

# AoikSocksVPN server's Shadowsocks server's Kcptun server's program inner
# command's extra options. Notice some options are required to be consistent
# for both server and client.
[ -z "$AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_KCPTUN_SERVER_PROG_INNER_CMD_EXTRA_OPTS" ] &&
AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_KCPTUN_SERVER_PROG_INNER_CMD_EXTRA_OPTS='--mode normal'

# Print info
echo "AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_KCPTUN_SERVER_PROG_INNER_CMD_EXTRA_OPTS=${AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_KCPTUN_SERVER_PROG_INNER_CMD_EXTRA_OPTS}"

# AoikSocksVPN server's Shadowsocks server's Kcptun server's program inner
# command
[ -z "$AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_KCPTUN_SERVER_PROG_INNER_CMD" ] &&
AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_KCPTUN_SERVER_PROG_INNER_CMD="${KCPTUN_SERVER_PROG} -l ${AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_KCPTUN_SERVER_HOST}:${AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_KCPTUN_SERVER_PORT} -t ${AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_HOST}:${AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_PORT} --key ${AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_KCPTUN_SERVER_ENCRYPT_KEY} ${AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_KCPTUN_SERVER_PROG_INNER_CMD_EXTRA_OPTS}"

# Print info
echo "AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_KCPTUN_SERVER_PROG_INNER_CMD=${AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_KCPTUN_SERVER_PROG_INNER_CMD}"

# AoikSocksVPN server's Shadowsocks server's Kcptun server's program PID file
# path
[ -z "$AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_KCPTUN_SERVER_PROG_PID_PATH" ] &&
AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_KCPTUN_SERVER_PROG_PID_PATH="${AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_KCPTUN_SERVER_PROG}.pid"

# Print info
echo "AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_KCPTUN_SERVER_PROG_PID_PATH=${AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_KCPTUN_SERVER_PROG_PID_PATH}"


# ----- Create AoikSocksVPN server's user -----
# Print info
echo
echo "# ----- Create AoikSocksVPN server's user -----"

# If the user is existing
if id -u "${AOIKSOCKSVPN_SERVER_USER}" &>/dev/null; then
    # Print info
    echo "User existing: ${AOIKSOCKSVPN_SERVER_USER}"

# If the user is not existing
else
    # Create user
    useradd "${AOIKSOCKSVPN_SERVER_USER}" -s /sbin/nologin

    # Print info
    echo "User created: ${AOIKSOCKSVPN_SERVER_USER}"
fi


# ----- Create AoikSocksVPN server's directory -----
# Print info
echo
echo "# ----- Create AoikSocksVPN server's directory -----"

# Create AoikSocksVPN server's directory
mkdir -pv "${AOIKSOCKSVPN_SERVER_DIR}"

# Change AoikSocksVPN server's directory's owner
chown "${AOIKSOCKSVPN_SERVER_USER}:${AOIKSOCKSVPN_SERVER_USER}" "${AOIKSOCKSVPN_SERVER_DIR}"

# Change AoikSocksVPN server's directory's modes
chmod 700 "${AOIKSOCKSVPN_SERVER_DIR}"

# ----- Create AoikSocksVPN server's Shadocsocks server's config file -----
# Print info
echo
echo "# ----- Create AoikSocksVPN server's Shadocsocks server's config file -----"

# If have existing config file
if [ -f "${AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_CONFIG_PATH}" ]; then
    # Print info
    echo 'Back up existing config file:'

    # Back up the existing config file
    mv -Tv "${AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_CONFIG_PATH}" "${AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_CONFIG_PATH}.bak.utc${SCRIPT_TIME}"
fi

# Create containing directory if not existing
mkdir -pv "$(dirname "${AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_CONFIG_PATH}")"

# Create AoikSocksVPN server's Shadocsocks server's config file
tee <<ZZZ "${AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_CONFIG_PATH}"
{
    "server": "${AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_HOST}",
    "server_port": ${AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_PORT},
    "password": "${AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_ENCRYPT_PASSWORD}",
    "method": "${AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_ENCRYPT_METHOD}",
    "nameserver": "${AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_NAMESERVER}",
    "timeout": 600,
    "auth": false
}
ZZZ

# Change the config file's owner
chown "${AOIKSOCKSVPN_SERVER_USER}:${AOIKSOCKSVPN_SERVER_USER}" "${AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_CONFIG_PATH}"

# Change the config file's modes
chmod 600 "${AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_CONFIG_PATH}"


# ----- Create AoikSocksVPN server's Shadowsocks server's program -----
echo
echo "# ----- Create AoikSocksVPN server's Shadowsocks server's program -----"

# Create containing directory if not existing
mkdir -pv "$(dirname "${AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_PROG}")"

# Create the program file
tee <<ZZZ "${AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_PROG}"
#!/usr/bin/env bash

# Set quit on error
set -e

# Set PATH
export PATH='${AOIKSOCKSVPN_SERVER_PROG_ENV_PATH}'

# If the PID file exists,
# and the PID in the PID file exists.
if [ -f '${AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_PROG_PID_PATH}' ] &&
    ps -p "\$(cat '${AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_PROG_PID_PATH}')" &>/dev/null ;
then
    # Print info
    echo "Error: AoikSocksVPN server's Shadowsocks server is running according to PID file: ${AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_PROG_PID_PATH}"
    echo
    echo 'To stop the running process, run:'
    echo "kill \"\\\$(cat '${AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_PROG_PID_PATH}')\""
    echo "rm -f '${AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_PROG_PID_PATH}'"
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
        return

    # If the trap function is not called before
    else
        # Set the variable be 1 to ignore next call
        EXIT_TRAP_IS_CALLED='1'
    fi

    # Remove AoikSocksVPN server's Shadowsocks server's program PID file
    rm -f '${AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_PROG_PID_PATH}' || true
}

# Hook the exit trap function
trap exit_trap EXIT SIGTERM SIGQUIT SIGABRT SIGINT SIGHUP

# Create PID file's containing directory if not existing
mkdir -pv "\$(dirname '${AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_PROG_PID_PATH}')"

# Start AoikSocksVPN server's Shadowsocks server
${AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_PROG_INNER_CMD} &

# Create PID file
echo "\$!" > '${AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_PROG_PID_PATH}'

# Wait for AoikSocksVPN server's Shadowsocks server to quit
wait
ZZZ

# Change the program file's owner
chown "${AOIKSOCKSVPN_SERVER_USER}:${AOIKSOCKSVPN_SERVER_USER}" "${AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_PROG}"

# Change the program file's modes
chmod 700 "${AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_PROG}"


# ----- Create AoikSocksVPN server's Shadowsocks server's Kcptun server's program -----
# Print info
echo
echo "# ----- Create AoikSocksVPN server's Shadowsocks server's Kcptun server's program -----"

# Create containing directory if not existing
mkdir -pv "$(dirname "${AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_KCPTUN_SERVER_PROG}")"

# Create the program file
tee <<ZZZ "${AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_KCPTUN_SERVER_PROG}"
#!/usr/bin/env bash

# Set quit on error
set -e

# Set PATH
export PATH='${AOIKSOCKSVPN_SERVER_PROG_ENV_PATH}'

# If the PID file exists,
# and the PID in the PID file exists.
if [ -f '${AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_KCPTUN_SERVER_PROG_PID_PATH}' ] &&
    ps -p "\$(cat '${AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_KCPTUN_SERVER_PROG_PID_PATH}')" &>/dev/null ;
then
    # Print info
    echo "Error: AoikSocksVPN server's Shadowsocks server's Kcptun server is running according to PID file: ${AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_KCPTUN_SERVER_PROG_PID_PATH}"
    echo
    echo 'To stop the running process, run:'
    echo "kill \"\\\$(cat '${AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_KCPTUN_SERVER_PROG_PID_PATH}')\""
    echo "rm -f '${AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_KCPTUN_SERVER_PROG_PID_PATH}'"
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
        return

    # If the trap function is not called before
    else
        # Set the variable be 1 to ignore next call
        EXIT_TRAP_IS_CALLED='1'
    fi

    # Remove AoikSocksVPN server's Shadowsocks server's Kcptun server's program PID file
    rm -f '${AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_KCPTUN_SERVER_PROG_PID_PATH}' || true
}

# Hook the exit trap function
trap exit_trap EXIT SIGTERM SIGQUIT SIGABRT SIGINT SIGHUP

# Create PID file's containing directory if not existing
mkdir -pv "\$(dirname '${AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_KCPTUN_SERVER_PROG_PID_PATH}')"

# Start AoikSocksVPN server's Shadowsocks server's Kcptun server
${AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_KCPTUN_SERVER_PROG_INNER_CMD} &

# Create PID file
echo "\$!" > '${AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_KCPTUN_SERVER_PROG_PID_PATH}'

# Wait for AoikSocksVPN server's Shadowsocks server's Kcptun server to quit
wait
ZZZ

# Change the program file's owner
chown "${AOIKSOCKSVPN_SERVER_USER}:${AOIKSOCKSVPN_SERVER_USER}" "${AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_KCPTUN_SERVER_PROG}"

# Change the program file's modes
chmod 700 "${AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_KCPTUN_SERVER_PROG}"


# ----- Create AoikSocksVPN server's program -----
echo
echo "# ----- Create AoikSocksVPN server's program -----"

# Create containing directory if not existing
mkdir -pv "$(dirname "${AOIKSOCKSVPN_SERVER_PROG}")"

# Create the program file
tee <<ZZZ "${AOIKSOCKSVPN_SERVER_PROG}"
#!/usr/bin/env bash

# Set quit on error
set -e

# Set PATH
export PATH='${AOIKSOCKSVPN_SERVER_PROG_ENV_PATH}'

# If is not running as root
if [ "$(id -u)" != '0' ]; then
    # Print info
    echo 'Error: This script must be run as root.'

    # Exit
    exit 1
fi

# If the PID file exists,
# and the PID in the PID file exists.
if [ -f '${AOIKSOCKSVPN_SERVER_PROG_PID_PATH}' ] &&
    ps -p "\$(cat '${AOIKSOCKSVPN_SERVER_PROG_PID_PATH}')" &>/dev/null ;
then
    # Print info
    echo "Error: AoikSocksVPN server is running according to PID file: ${AOIKSOCKSVPN_SERVER_PROG_PID_PATH}"
    echo
    echo 'To stop the running process, run:'
    echo "kill \"\\\$(cat '${AOIKSOCKSVPN_SERVER_PROG_PID_PATH}')\""
    echo "rm -f '${AOIKSOCKSVPN_SERVER_PROG_PID_PATH}'"
    echo

    # Exit
    exit 1

# If the PID file not exists,
# or the PID in the PID file not exists.
else
    # Create containing directory if not existing
    mkdir -pv "\$(dirname '${AOIKSOCKSVPN_SERVER_PROG_PID_PATH}')"

    # Create PID file
    echo "\$\$" > '${AOIKSOCKSVPN_SERVER_PROG_PID_PATH}'
fi

# Whether the exit trap function is called before
EXIT_TRAP_IS_CALLED=''

# Create exit trap function
function exit_trap {
    # If the exit trap function is called before
    if [ -n "\${EXIT_TRAP_IS_CALLED}" ]; then
        # Return
        return

    # If the trap function is not called before
    else
        # Set the variable be 1 to ignore next call
        EXIT_TRAP_IS_CALLED='1'
    fi

    # Remove AoikSocksVPN server's PID file
    rm -f '${AOIKSOCKSVPN_SERVER_PROG_PID_PATH}' || true

    # If the PID variable value is GT 1
    if [ "\$AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_KCPTUN_SERVER_PROG_PID" -gt '1' ] 2>/dev/null ; then
        # Stop AoikSocksVPN server's Shadowsocks server's Kcptun server
        kill "\${AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_KCPTUN_SERVER_PROG_PID}" 2>/dev/null || true
    fi

    # If the PID variable value is GT 1
    if [ "\$AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_PROG_PID" -gt '1' ] 2>/dev/null ; then
        # Stop AoikSocksVPN server's Shadowsocks server
        kill "\${AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_PROG_PID}" 2>/dev/null || true
    fi
}

# Hook the exit trap function
trap exit_trap EXIT SIGTERM SIGQUIT SIGABRT SIGINT SIGHUP

# Start AoikSocksVPN server's Shadowsocks server
sudo -u '${AOIKSOCKSVPN_SERVER_USER}' bash '${AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_PROG}' &

# Wait for AoikSocksVPN server's Shadowsocks server's process to start and
# write PID file
sleep 1

# If the PID file not exists,
# or the PID in the PID file not exists.
if ! {
    [ -f '${AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_PROG_PID_PATH}' ] &&
    AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_PROG_PID="\$(cat '${AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_PROG_PID_PATH}')" &&
    ps -p "\${AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_PROG_PID}" &>/dev/null
} ; then
    # Print info
    echo "Error: Failed starting AoikSocksVPN server's Shadowsocks server."

    # Exit
    exit 1
fi

# Start AoikSocksVPN server's Shadowsocks server's Kcptun server
sudo -u '${AOIKSOCKSVPN_SERVER_USER}' bash '${AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_KCPTUN_SERVER_PROG}' &

# Wait for AoikSocksVPN server's Shadowsocks server's Kcptun server's process
# to start and write PID file
sleep 1

# If the PID file not exists,
# or the PID in the PID file not exists.
if ! {
    [ -f '${AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_KCPTUN_SERVER_PROG_PID_PATH}' ] &&
    AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_KCPTUN_SERVER_PROG_PID="\$(cat '${AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_KCPTUN_SERVER_PROG_PID_PATH}')" &&
    ps -p "\${AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_KCPTUN_SERVER_PROG_PID}" &>/dev/null
} ; then
    # Print info
    echo "Error: Failed starting AoikSocksVPN server's Shadowsocks server's Kcptun server."

    # Exit
    exit 1
fi

# Loop forever
while :;
do
    # For each background process's PID
    for pid in \\
        "\${AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_PROG_PID}" \\
        "\${AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_KCPTUN_SERVER_PROG_PID}" ;
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
chown 'root:root' "${AOIKSOCKSVPN_SERVER_PROG}"

# Change the program file's modes
chmod 700 "${AOIKSOCKSVPN_SERVER_PROG}"

# If the symbolic link path is not EQ the program path
if [ "${AOIKSOCKSVPN_SERVER_PROG_SYMLINK}" != "${AOIKSOCKSVPN_SERVER_PROG}" ]; then
    # Create containing directory if not existing
    mkdir -pv "$(dirname "${AOIKSOCKSVPN_SERVER_PROG_SYMLINK}")"

    # Remove symbolic link path if existing
    rm -f "${AOIKSOCKSVPN_SERVER_PROG_SYMLINK}"

    # Create symbolic link
    ln -sv "${AOIKSOCKSVPN_SERVER_PROG}" "${AOIKSOCKSVPN_SERVER_PROG_SYMLINK}"
fi


# ----- Create AoikSocksVPN server's service -----
# Print info
echo
echo "# ----- Create AoikSocksVPN server's service -----"

# If SystemD's `systemctl` command is not found
if ! command -v 'systemctl' &>/dev/null; then
    # Print info
    echo "SystemD's \`systemctl\` command is not found. Ignore."

# If SystemD's `systemctl` command is found
else
    # Print info
    echo
    echo "# ----- Create SystemD service config \`${AOIKSOCKSVPN_SERVER_SYSTEMD_SERVICE_CONFIG_PATH}\` -----"

    # If have existing config file
    if [ -f "${AOIKSOCKSVPN_SERVER_SYSTEMD_SERVICE_CONFIG_PATH}" ]; then
        # Print info
        echo 'Back up existing config file:'

        # Back up the existing config file
        mv -Tv "${AOIKSOCKSVPN_SERVER_SYSTEMD_SERVICE_CONFIG_PATH}" "${AOIKSOCKSVPN_SERVER_SYSTEMD_SERVICE_CONFIG_PATH}.bak.utc${SCRIPT_TIME}"
    fi

    # Create containing directory if not existing
    mkdir -pv "$(dirname "${AOIKSOCKSVPN_SERVER_SYSTEMD_SERVICE_CONFIG_PATH}")"

    # Create SystemD service config
    tee <<ZZZ "${AOIKSOCKSVPN_SERVER_SYSTEMD_SERVICE_CONFIG_PATH}"
[Unit]
After=network.target

[Service]
Type=simple
User=root
ExecStart=${AOIKSOCKSVPN_SERVER_PROG}
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


# ----- Usage: Locate AoikSocksVPN server programs -----
# Print info
echo
echo "# ----- Usage: Locate AoikSocksVPN server programs -----"

# Locate programs
which "${AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_KCPTUN_SERVER_PROG}"

which "${AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_PROG}"

which "${AOIKSOCKSVPN_SERVER_PROG}"

# If the symbolic link path is not EQ the program path
if [ "${AOIKSOCKSVPN_SERVER_PROG_SYMLINK}" != "${AOIKSOCKSVPN_SERVER_PROG}" ]; then
    # Locate the symbolic link path
    which "${AOIKSOCKSVPN_SERVER_PROG_SYMLINK}"
fi


# ----- Usage: Start AoikSocksVPN server service -----
# Print info
echo
echo "# ----- Usage: Start AoikSocksVPN server service -----"

# If SystemD's `systemctl` command is not found
if ! command -v 'systemctl' &>/dev/null; then
    # Print info
    echo "SystemD's \`systemctl\` command is not found. Ignore."

# If SystemD's `systemctl` command is found
else
    # Print info
    cat <<ZZZ
# Start AoikSocksVPN server service
systemctl start '${AOIKSOCKSVPN_SERVER_SYSTEMD_SERVICE_NAME}.service'

# Stop AoikSocksVPN server service
systemctl stop '${AOIKSOCKSVPN_SERVER_SYSTEMD_SERVICE_NAME}.service'

# Check AoikSocksVPN server service status
systemctl status '${AOIKSOCKSVPN_SERVER_SYSTEMD_SERVICE_NAME}.service'

# Check service error log
journalctl -ex
ZZZ
fi


# ----- Usage: Configure Sudo -----
# Print info
echo
cat <<ZZZ
# ----- Usage: Configure Sudo -----
Running AoikSocksVPN server service requires adjusting Sudo config.

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
