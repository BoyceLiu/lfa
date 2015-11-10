#!/bin/bash
echo Yong:1|sudo chpasswd
if [ -z "$1" ]
then
	echo "need an argument as a part of ovs dpid\n"
	echo "such as 01,09,0a,11"
	exit
fi

sudo apt-get update -q=2
sudo apt-get install -y vim openvswitch-switch dkms axel
axel --quiet http://download.virtualbox.org/virtualbox/5.0.8/virtualbox-5.0_5.0.8-103449~Ubuntu~precise_amd64.deb
sudo dpkg -i virtualbox-5.0_5.0.8-103449~Ubuntu~precise_amd64.deb
sudo apt-get -f install -y
axel -q http://download.virtualbox.org/virtualbox/5.0.8/Oracle_VM_VirtualBox_Extension_Pack-5.0.8-103449.vbox-extpack
sudo vboxmanage extpack install Oracle_VM_VirtualBox_Extension_Pack-5.0.8-103449.vbox-extpack
echo "************ vim openvswitch-switch virtualbox is installed *****************"

sudo ovs-vsctl add-br br0 
sudo ovs-vsctl set bridge br0 other-config:datapath-id=00aa00bb00cc00$1;

function add_port()
{
	ovs=${1};
	node=${2};

	echo $ovs --tap port-- $node;
	port=vnet-${ovs}-${node};

	sudo ip tuntap add mode tap $port;
	sudo ip link set $port up;
	sudo ovs-vsctl add-port $ovs $port;
}

add_port br0 h1
add_port br0 h2
add_port br0 h3
echo "************ ovs and port is created *****************"

# create vm and start them
# requirement:
# 1. openvswitch br0 and vnet-port
# 2. VirtualBox and extpack installed

vboxmanage import host.ova
vboxmanage modifyvm host --name h1
vboxmanage import host.ova
vboxmanage modifyvm host --name h2
vboxmanage import host.ova
vboxmanage modifyvm host --name h2

vboxmanage hostonlyif create

vboxmanage modifyvm h1 --nic2 bridged
vboxmanage modifyvm h1 --bridgeadapter2 vnet-br0-h1
vboxmanage modifyvm h1 --nic3 hostonly
vboxmanage modifyvm h1 --hostonlyadapter3 vboxnet0

vboxmanage modifyvm h2 --nic2 bridged
vboxmanage modifyvm h2 --bridgeadapter2 vnet-br0-h2
vboxmanage modifyvm h2 --nic3 hostonly
vboxmanage modifyvm h2 --hostonlyadapter3 vboxnet0

vboxmanage modifyvm h3 --nic2 bridged
vboxmanage modifyvm h3 --bridgeadapter2 vnet-br0-h3
vboxmanage modifyvm h3 --nic3 hostonly
vboxmanage modifyvm h3 --hostonlyadapter3 vboxnet0

vboxmanage startvm h1 --type headless
vboxmanage startvm h2 --type headless
vboxmanage startvm h3 --type headless
