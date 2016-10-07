# AoikSocksVPN
Create VPN in one-liners with Shadowsocks, Kcptun and BadVPN Tun2Socks.

The VPN works this way: Packets headed for target host -> Kernel routing -> Tun virtual interface -> BadVPN Tun2Socks virtual router -> Shadowsocks client -> Kcptun client ---> Kcptun server -> Shadowsocks server ---> Target host

Tested working with:
- CentOS 5.11
- CentOS 6.8
- CentOS 7.2
- Oracle Linux 5.9
- Oracle Linux 6.8
- Oracle Linux 7.2
- Fedora 24
- Debian 7.11
- Debian 8.6
- Ubuntu 14.04
- Ubuntu 16.04
- Linux Mint 18

## Table of Contents
- [Usage](#usage)
  - [Download this repository](#download-this-repository)
  - [Set up OS package repository configs](#set-up-os-package-repository-configs)
  - [Set up Kcptun](#set-up-kcptun)
  - [Set up Shadowsocks](#set-up-shadowsocks)
  - [Set up BadVPN](#set-up-badvpn)
  - [Set up AoikSocksVPN server](#set-up-aoiksocksvpn-server)
  - [Start AoikSocksVPN server](#start-aoiksocksvpn-server)
  - [Set up AoikSocksVPN client](#set-up-aoiksocksvpn-client)
  - [Start AoikSocksVPN client](#start-aoiksocksvpn-client)

## Usage

### Download this repository
Run:
```
# Download this repository's archive file
wget https://github.com/AoiKuiyuyou/AoikSocksVPN/archive/master.zip -O AoikSocksVPN-master.zip

# Extract the archive file to directory
unzip AoikSocksVPN-master.zip

# Rename the extracted directory
mv -Tv AoikSocksVPN-master AoikSocksVPN
```

### Set up OS package repository configs
See [AoikOSPackageManagerHowto](https://github.com/AoiKuiyuyou/AoikOSPackageManagerHowto/)
for setting up OS package repository configs so that OS packages can be
downloaded from a faster mirror repository.

### Set up Kcptun
Run on both VPN server and client sides:
```
sudo PATH="$PATH" bash AoikSocksVPN/tools/kcptun/kcptun-setup.sh
```

### Set up Shadowsocks
Run on both VPN server and client sides:
```
sudo PATH="$PATH" bash AoikSocksVPN/tools/shadowsocks/shadowsocks-libev-setup.sh
```

### Set up BadVPN
Run on VPN client side:
```
sudo PATH="$PATH" bash AoikSocksVPN/tools/badvpn/badvpn-setup.sh
```

### Set up AoikSocksVPN server
Run on VPN server side:
```
sudo PATH="$PATH" \
    AOIKSOCKSVPN_SERVER_DIR='/opt/aoiksocksvpn-server' \
    AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_HOST='127.0.0.1' \
    AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_PORT='2080' \
    AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_ENCRYPT_PASSWORD='(_TWEAK_THIS_)' \
    AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_ENCRYPT_METHOD='aes-256-cfb' \
    AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_KCPTUN_SERVER_HOST='(_TWEAK_THIS_)' \
    AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_KCPTUN_SERVER_PORT='2090' \
    AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_KCPTUN_SERVER_ENCRYPT_KEY='(_TWEAK_THIS_)' \
    AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_KCPTUN_SERVER_PROG_INNER_CMD_EXTRA_OPTS='--mode normal' \
    bash AoikSocksVPN/tools/aoiksocksvpn/aoiksocksvpn-server-setup.sh
```

This setup script can be re-run after tweaking these environment variables. It will
print program usage in the end.

### Start AoikSocksVPN server
Run on VPN server side:
```
sudo PATH="$PATH" bash aoiksocksvpn-server
```

### Set up AoikSocksVPN client
Run on VPN client side:
```
sudo \
    PATH="$PATH" \
    AOIKSOCKSVPN_CLIENT_DIR='/opt/aoiksocksvpn-client' \
    AOIKSOCKSVPN_CLIENT_ORIG_GATEWAY_HOST='(_TWEAK_THIS_)' \
    AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_KCPTUN_SERVER_HOST='(_TWEAK_THIS_)' \
    AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_KCPTUN_SERVER_PORT='2090' \
    AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_KCPTUN_SERVER_ENCRYPT_KEY='(_TWEAK_THIS_)' \
    AOIKSOCKSVPN_CLIENT_SHADOWSOCKS_CLIENT_KCPTUN_CLIENT_HOST='127.0.0.1' \
    AOIKSOCKSVPN_CLIENT_SHADOWSOCKS_CLIENT_KCPTUN_CLIENT_PORT='1090' \
    AOIKSOCKSVPN_CLIENT_SHADOWSOCKS_CLIENT_KCPTUN_CLIENT_PROG_INNER_CMD_EXTRA_OPTS='--mode normal' \
    AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_ENCRYPT_PASSWORD='(_TWEAK_THIS_)' \
    AOIKSOCKSVPN_SERVER_SHADOWSOCKS_SERVER_ENCRYPT_METHOD='aes-256-cfb' \
    AOIKSOCKSVPN_CLIENT_SHADOWSOCKS_CLIENT_HOST='127.0.0.1' \
    AOIKSOCKSVPN_CLIENT_SHADOWSOCKS_CLIENT_PORT='1080' \
    AOIKSOCKSVPN_CLIENT_TUN2SOCKS_INTERFACE_HOST='10.255.0.2' \
    AOIKSOCKSVPN_CLIENT_TUN2SOCKS_ROUTER_HOST='10.255.0.1' \
    AOIKSOCKSVPN_CLIENT_TUN2SOCKS_NETMASK='255.255.255.0' \
    bash AoikSocksVPN/tools/aoiksocksvpn/aoiksocksvpn-client-setup.sh
```

This setup script can be re-run after tweaking these environment variables. It will
print program usage in the end.

### Start AoikSocksVPN client
Run on VPN client side:
```
sudo PATH="$PATH" bash aoiksocksvpn-client
```
