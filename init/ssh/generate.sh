#!/usr/bin/env bash

TMP_BASE_DIR=/tmp/ssh-udf

echo "Creating temporary output folders"
mkdir -p ${TMP_BASE_DIR}/k8s-master
mkdir -p ${TMP_BASE_DIR}/k8s-node1
mkdir -p ${TMP_BASE_DIR}/k8s-node2
mkdir -p ${TMP_BASE_DIR}/k8s-node3
mkdir -p ${TMP_BASE_DIR}/consul-connect

echo "Generating ssh key pairs"
ssh-keygen -b 2048 -t rsa -f ${TMP_BASE_DIR}/k8s-master/id_rsa     -C ubuntu@k8s-master     -q -N ""
ssh-keygen -b 2048 -t rsa -f ${TMP_BASE_DIR}/k8s-node1/id_rsa      -C ubuntu@k8s-node1      -q -N ""
ssh-keygen -b 2048 -t rsa -f ${TMP_BASE_DIR}/k8s-node2/id_rsa      -C ubuntu@k8s-node2      -q -N ""
ssh-keygen -b 2048 -t rsa -f ${TMP_BASE_DIR}/k8s-node3/id_rsa      -C ubuntu@k8s-node3      -q -N ""
ssh-keygen -b 2048 -t rsa -f ${TMP_BASE_DIR}/consul-connect/id_rsa -C ubuntu@consul-connect -q -N ""

echo "Moving ssh keypairs to repo"
mv ${TMP_BASE_DIR}/* .
