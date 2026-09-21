
## Quick Config

### 1. Network setup
```bash
/interface/veth/add name=veth1 address=172.17.0.2/24 gateway=172.17.0.1
/interface/bridge/add name=containers
/ip/address/add address=172.17.0.1/24 interface=containers
/interface/bridge/port add bridge=containers interface=veth1
/ip/firewall/nat/add chain=srcnat action=masquerade src-address=172.17.0.0/24
/ip/firewall/nat/add chain=srcnat action=masquerade out-interface=containers
```

### 2.  Container environment variables
```bash
/container/envs/add key=ANYCONNECT_PASSWORD name=openconnect value="password"
/container/envs/add key=ANYCONNECT_SERVER name=openconnect value="server_url"
/container/envs/add key=ANYCONNECT_USER name=openconnect value="user"
```
`ANYCONNECT_CERT` is optional. Add it only when OpenConnect cannot verify the server certificate through a standard certificate authority, for example when the VPN uses a self-signed certificate or a private CA:
```bash
add key=ANYCONNECT_CERT name=openconnect value="value"
```
The pin ensures the container connects only to the correct VPN server.
To generate it for your server:
```bash
echo | openssl s_client -connect <VPN_SERVER>:443 2>/dev/null \
  | openssl x509 -pubkey -noout \
  | openssl pkey -pubin -outform DER \
  | openssl dgst -sha256 -binary | base64
```

### 3. Container configuration
```bash
/container/config/set registry-url=https://registry-1.docker.io tmpdir=/docker/tmp
/container add remote-image=gritsenko/openconnect-mikrotik:latest interface=veth1 envlist=openconnect root-dir=/docker/openconnect start-on-boot=no dns=8.8.8.8 hostname=openconnect logging=yes
/container start number=0
````
