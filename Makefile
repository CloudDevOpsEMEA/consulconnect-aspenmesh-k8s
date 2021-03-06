# Makefile

GIT_REPO=https://github.com/CloudDevOpsEMEA/consulconnect-aspenmesh-k8s
HOME_DIR=/home/ubuntu
REPO_DIR=${HOME_DIR}/consulconnect-aspenmesh-k8s


.PHONY: help

help: ## This help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z0-9_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help


install-k8s: ## Install k8s using kubespray
	cd /tmp && git clone https://github.com/kubernetes-sigs/kubespray.git && \
	cd kubespray && git checkout release-2.14 && \
	cp -R ${REPO_DIR}/kubespray/istio /tmp/kubespray/inventory && \
	sudo pip3 install -r requirements.txt && \
	ansible-playbook -i inventory/istio/hosts.yaml  --become --become-user=root cluster.yml


install-kubectl: ## Install kubectl
	sudo snap install kubectl --classic
	sudo mkdir -p ~/.kube
	sudo touch ~/.kube/config
	sudo cp /etc/kubernetes/admin.conf ~/.kube/config || true
	sudo chown ubuntu:ubuntu -R ~/.kube
	sudo chmod 600 -R ~/.kube/config
	echo '' >>~/.bashrc
	echo '# Kubernetes' >>~/.bashrc
	echo 'export KUBECONFIG=/home/ubuntu/.kube/config' >>~/.bashrc
	echo 'source <(kubectl completion bash)' >>~/.bashrc
	echo 'alias k=kubectl' >>~/.bashrc
	echo 'complete -F __start_kubectl k' >>~/.bashrc


reboot-k8s: ## Reboot k8s cluster hosts
	ssh k8s-master sudo reboot || true
	ssh k8s-node1 sudo reboot || true
	ssh k8s-node2 sudo reboot || true
	ssh k8s-node3 sudo reboot || true


reboot-consul: ## Reboot consul cluster hosts
	ssh consul-connect sudo reboot || true


git-clone-all: ## Clone all git repos
	ssh k8s-master   	 'cd ${HOME_DIR} ; git clone ${GIT_REPO}' || true
	ssh k8s-node1      'cd ${HOME_DIR} ; git clone ${GIT_REPO}' || true
	ssh k8s-node2      'cd ${HOME_DIR} ; git clone ${GIT_REPO}' || true
	ssh k8s-node3      'cd ${HOME_DIR} ; git clone ${GIT_REPO}' || true
	ssh consul-connect 'cd ${HOME_DIR} ; git clone ${GIT_REPO}' || true



git-pull-all: ## Pull all git repos
	ssh k8s-master     'cd ${REPO_DIR}; git pull ; sudo updatedb' || true
	ssh k8s-node1      'cd ${REPO_DIR}; git pull ; sudo updatedb' || true
	ssh k8s-node2      'cd ${REPO_DIR}; git pull ; sudo updatedb' || true
	ssh k8s-node3      'cd ${REPO_DIR}; git pull ; sudo updatedb' || true
	ssh consul-connect 'cd ${REPO_DIR}; git pull ; sudo updatedb' || true
