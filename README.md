
## Quick Config

### 1. Install container package

Make sure the container package is installed on your Mikrotik router.

### 2. Enable container mode
```bash
/system/device-mode/update container=yes
```
you will need to confirm the device-mode with a press of the reset button

### 3. Network setup
```bash
/interface/veth/add name=veth1 address=172.17.0.2/24 gateway=172.17.0.1
/interface/bridge/add name=containers
/ip/address/add address=172.17.0.1/24 interface=containers
/interface/bridge/port add bridge=containers interface=veth1
/ip/firewall/nat/add chain=srcnat action=masquerade out-interface=containers
```

### 4.  Container environment variables
```bash
add key=ANYCONNECT_PASSWORD name=openconnect value="password"
add key=ANYCONNECT_SERVER name=openconnect value="server_url"
add key=ANYCONNECT_USER name=openconnect value="user"
add key=ANYCONNECT_CERT name=openconnect value="value" 
```
About ANYCONNECT_CERT. This is especially necessary if you are using a self-signed certificate, because OpenConnect cannot verify it through a standard certificate authority. The pin ensures the container connects only to the correct VPN server.
To generate it for your server:
```bash
echo | openssl s_client -connect <VPN_SERVER>:443 2>/dev/null \
  | openssl x509 -pubkey -noout \
  | openssl pkey -pubin -outform DER \
  | openssl dgst -sha256 -binary | base64
```

### 5. Container configuration
```bash
/container/config/set registry-url=https://registry-1.docker.io tmpdir=/docker/tmp
/container add remote-image=gritsenko/openconnect-mikrotik:latest interface=veth1 envlist=openconnect root-dir=/docker/openconnect start-on-boot=yes hostname=openconnect logging=yes
/container start number=0
````