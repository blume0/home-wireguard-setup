# Log of me setting up a home WireGuard server

## Hardware
  - A Raspberry Pi 4 model B
  - A 4Gb microSD card
  - A USB-C cable and a power adapter for the Pi
  - An external computer with an SD card slot to setup everything (on Ubuntu for me)

## I. Installing Linux and needed dependencies in the Raspi
1. Installing an Ubuntu image in the SD card (using the setup computer)
    - Install the 'rpi-imager' package on the computer : `sudo apt-get install rpi-imager`
    - Download the latest LTS Ubuntu Server image from (here)[https://ubuntu.com/download/raspberry-pi/thank-you?version=24.04.2&architecture=server-arm64+raspi]
    - Plug the SD card in the computer, launch rpi-imager and select the SD card and the downloaded image file
    - Setup settings :
        - login and password
        - host name
        - wifi name and password (to ease configuration without ethernet on startup)
        - ssh settings : add the public key of the setup computer to be able to login without a password, and disable password login if you ever intend to expose ssh access over the internet
    - Proceed with the installation
    - Unplug the SD card when finished
2. Booting the Raspi and accessing it via ssh
    - Plug the SD card in the Raspi
    - Plug the USB-C power cable (the Raspi will boot automatically)
    - Wait a few moments for it to boot up and connect to the WIFI (or else connect it to the local network via Ethernet)
    - Find the IP address of the Raspi (for example, through the web interface of the router/internet box and identifying the chosen host name).
    - From the host computer, login to this ip address with the command `ssh chosen_login@ip_address`
3. Install dependencies
    - Uptade the sources and upgrade everything : `sudo apt-get update && sudo apt-get upgrade`
    - Install network tools for debugging `apt install netcat-openbsd tcpdump net-tools`
    - Install wireguard `apt install wireguard wireguard-tools iptables`

## II. Configuring WireGuard
1. Set linux kernel port forwarding
    - In /etc/sysctl.conf add or uncomment the line `net.ipv4.ip_forward=1` (after creating the file if it does not exist)
    - Update the kernel configuration with `sudo sysctl -p`
    - Check that `cat /proc/sys/net/ipv4/ip_forward` outputs "1"
2. Generate keys and initialize configuration file for WireGuard
    - `sudo -s`
    - `cd /etc/wireguard`
    -  Run `ifconfig -a` and find the used ETH-DEVICE (probably eth0 for ethernet and wlan0 for wifi)
    -  Generate key-pair : `wg genkey | tee server-privatekey | wg pubkey > server-publickey`
    -  `chmod 600 server-privatekey`
    -  Make config file: create a file named wg0.conf with the following content
       ```
       [Interface]
       Address = 10.20.10.1/24
       ListenPort = 33333
       PrivateKey = [THE GENERATED PRIVATE KEY]
       PostUp = iptables -A FORWARD -i wg0 -j ACCEPT
       PostUp = iptables -t nat -A POSTROUTING -o [ETH-DEVICE] -j MASQUERADE
       PostDown = iptables -D FORWARD -i wg0 -j ACCEPT
       PostDown = iptables -t nat -D POSTROUTING -o [ETH-DEVICE] -j MASQUERADE

       ```
    - `chmod 600 wg0.conf`
    - `systemctl enable wg-quick@wg0 && systemctl start wg-quick@wg0`
    - `logout` to exit root shell and go back to home
    - `mkdir wireguard-clients` folder for clients
3. Setup client list
    - `mkdir wireguard-clients` folder for clients
    - FROM THE HOST MACHINE NOT THE RASPI: copy the add_client.sh script to the raspi
      `scp add_client.sh [login]@[ip_address]:./add_client.sh`
    - `chmod u+x add_client.sh`

## III. Configuring internet router/box and DDNS address
...

## IV. Creating new clients
1. Creating a client:
    - To create a new "account", from the Raspi home execute `sudo ./add_client.sh [account_new_name] 10.20.10.xxx [public_pi_address]`  where the xxx refers to an ip never used before. This will generate a file `./wireguard-clients/account_new_name.conf`, this is the file we have to give to the owner of the account.
    - FROM THE HOST MACHINE: `scp [login]@public_address:./wireguard-clients/new_account_name.conf .` to get the file, then share the file with the client

2. If a client was created with a bad configutation, it can be removed manually from
   the /etc/wireguard/wg0.conf file

## V. Client-side connection
  Simply install WireGuard client for the device (Windows PC, Android smartphone, IPhone) and open the shared configuration file in it
