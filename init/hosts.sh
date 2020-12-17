#!/usr/bin/env bash

sudo tee -a /etc/hosts << END

# Host aliases for the UDF systems
10.1.1.4    k8s-master
10.1.1.5    k8s-node1
10.1.1.6    k8s-node2
10.1.1.7    k8s-node3
10.1.1.8    consul-connect
END
