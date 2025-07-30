#!/bin/bash


server_conf_dir=/etc/wireguard
server_conf_file=wg0.conf
client_out_dir=./wireguard-clients
client_name=$1
client_ip=$2
endpoint=$3

client="$client_out_dir/$client_name"

private_key=$(wg genkey)
public_key=$(echo $private_key | wg pubkey)
server_key=$(cat $server_conf_dir/server-publickey)
echo $private_key > "$client"-privatekey
echo $public_key > "$client"-publickey

c="$client".conf
rm $c 2>/dev/null

echo "[Interface]" >> $c
echo "Address = $client_ip/24" >> $c
echo "ListenPort = 33333" >> $c
echo "DNS = 8.8.8.8" >> $c
echo "PrivateKey" "=" $private_key >> $c

echo >> $c

echo "[Peer]" >> $c
echo "PublicKey =" $server_key >> $c
echo "EndPoint =" $endpoint:33333 >> $c
echo "AllowedIPs = 0.0.0.0/0" >> $c


sconf=$server_conf_dir/$server_conf_file
cp $sconf $sconf.bak.$(date +%Y%m%d-%H%M%S)

echo >> $sconf
msg="CLIENT's $client_name CONF, ADDED ON $(date)"
echo "# $msg" >> $sconf
echo $msg
echo "[Peer]" >> $sconf
echo "AllowedIPs" "=" $client_ip >> $sconf
echo "PublicKey" "=" $public_key >> $sconf

systemctl reload wg-quick@wg0
