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
    - Setup settings : login and password, host name (remember that one), wifi loghin and password (to ease configuration without ethernet on startup), and ssh settings (PUBLICKEY ONLY !!) and add the public key of the setup computer
    - Proceed with the installation
    - Unplug the SD card when finished
2. Booting the Raspi and accessing it via ssh
    - Plug the SD card in the Raspi
    - Plug the USB-C power cable (the Raspi will boot automatically)
    - Wait a few moments for it to boot up and connect to the WIFI (or else connect it to the local network via Ethernet)
    - Find the IP address of the Raspi (for example, through the web interface of the router/internet box and identifying the chosen host name). If you can't locate it, the chosen hostname can also be used.
    - From the host computer, login to this ip address with the command `ssh chosen_login@chosen_hostname` or `ssh chosen_login@ip_address`
3. Install dependencies
    - Uptade the sources and upgrade everything : `sudo apt-get update && sudo apt-get upgrade`
    - Install network tools for debugging `apt install netcat-openbsd tcpdump`
    - Install wireguard `apt install wireguard wireguard-tools iptables`

## II. Configuring WireGuard
1. Set linux kernel port forwarding
    - In /etc/sysctl.conf add or uncomment the line `net.ipv4.ip_forward=1` (after creating the file if it does not exist)
    - Update the kernel configuration with `sudo sysctl -p`
    - Check that `cat /proc/sys/net/ipv4/ip_forward` outputs "1"
2. Generate keys and initialize configuration file for WireGuard
    - `sudo -s`
    - `cd /etc/wireguard`
    -  Generate key-pair : `wg genkey | tee server-privatekey | wg pubkey > server-publickey`
    -  `chmod 600 server-privatekey`
    -  Make config file: create a file named wg0.conf with the following content
       ```
       [Interface]
       ## Local Address : A private IP address for wg0 interface.
       Address = 10.20.10.1/24
       ListenPort = 33333
       ```