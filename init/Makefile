# Makefile
.PHONY: help

help: ## This help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z0-9_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

hostname: ## Change hostname and reboot
	./hostname.sh

init: ## Prepare host
	./password.sh
	./ssh.sh
	./update.sh
	./packages.sh
	./hosts.sh

calico: ## Install calicoctl
	./calicoctl.sh

dist-upgrade: ## Upgrade ubuntu version
	sudo do-release-upgrade -d 

grub: ## Enable cgroup_enable en swapaccount in grub
	./grub.sh
