#!/bin/bash

# Other (datacenter?) - print the source address of the route to the internet
ip -o route get 1.1.1.1 | cut -d ' ' -f 8

# EXAMPLE
# root@k8s-master-01:~# ip -o route get 1.1.1.1
# 1.1.1.1 via 192.168.1.1 dev enp0s3  src 192.168.1.241 \    cache
