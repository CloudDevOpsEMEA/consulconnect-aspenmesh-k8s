#!/usr/bin/env bash

IP_ADDRESS=$(hostname -I | cut -d' ' -f1)

case ${IP_ADDRESS} in

  "10.1.1.4")
    sudo sh -c "echo k8s-master > /etc/hostname" ; sudo init 6
    ;;
  "10.1.1.5")
    sudo sh -c "echo k8s-node1 > /etc/hostname" ; sudo init 6
    ;;
  "10.1.1.6")
    sudo sh -c "echo k8s-node2 > /etc/hostname" ; sudo init 6
    ;;
  "10.1.1.7")
    sudo sh -c "echo k8s-node3 > /etc/hostname" ; sudo init 6
    ;;
  "10.1.1.8")
    sudo sh -c "echo consul-connect > /etc/hostname" ; sudo init 6
    ;;

esac
