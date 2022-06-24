#!/bin/bash

#variables
key='p_key'
net='p_network'
subpool='p_pool'
sub='p-subnet'
router='p_router'
port='p_port'
port1='p_port1'
port2='p_port2'
secgroup='p_security'
proxy='p-tag_HAproxy'
bastion='p-tag_bastion'
node1='p-tag_node1'
node2='p-tag_node2'
node3='p-tag_node3'
img='235d9bfb-7a13-4434-9966-cfc0ae033e79'
fl='1C-1GB-20GB'

#key 
openstack keypair create $key

#Network
openstack network create --tag p-tag $net -f json

#subnet pool
openstack subnet pool create --pool-prefix 10.0.1.0/24 --tag p-tag $subpool

#subnet
openstack subnet create --subnet-pool $subpool --prefix-length 27 --dhcp --gateway 10.0.1.1 --ip-version 4 --network $net --tag p-tag $sub
#router
openstack router create --tag p-tag $router

#port
openstack port create --network $net --tag p-tag $port
openstack port create --network $net --tag p-tag $port1
openstack port create --network $net --tag p-tag $port2
#router add properties
openstack router add port $router $port
openstack router add subnet $router $sub
openstack router set --external-gateway ext-net $router

#security group
openstack security group create --tag p-tag $secgroup
#rule
openstack security group rule create --remote-ip 0.0.0.0/0 --dst-port 22 --protocol tcp --ingress $secgroup
openstack security group rule create --remote-ip 0.0.0.0/0 --dst-port 80 --protocol icmp --ingress $secgroup

#nodes
openstack server create --image $img --flavor $fl --key-name $key --network $net --security-group $secgroup $proxy
openstack server create --image $img --flavor $fl --key-name $key --network $net --security-group $secgroup $bastion
openstack server create --image $img --flavor $fl --key-name $key --network $net --security-group $secgroup $node1
openstack server create --image $img --flavor $fl --key-name $key --network $net --security-group $secgroup $node2
openstack server create --image $img --flavor $fl --key-name $key --network $net --security-group $secgroup $node3

#floating ip
openstack floating ip create ext-net -f json | -jq -r '.floating_ip_address' > floating_ip
echo "Floating IP: $(cat floating_ip)"
fip1="$(cat floating_ip)"
openstack floating ip create ext-net -f json | jq -r '.floating_ip_address' > floating_ip
echo "Floating IP: $(cat floating_ip)"
fip2="$(cat floating_ip)"
#adding floating ip
openstack server add floating $proxy $fip1
openstack server add floating $bastion $fip2