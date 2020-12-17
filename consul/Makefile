# Makefile

CONSULT_VERSION=1.9.0

.PHONY: help

help: ## This help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z0-9_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help


install-master:  ## Install consul server (bootstrap server with UI)
	sudo apt-get install -y unzip gnupg2 curl wget consul
	cd /tmp && \
	wget https://releases.hashicorp.com/consul/${CONSULT_VERSION}/consul_${CONSULT_VERSION}_linux_amd64.zip && \
	unzip consul_${CONSULT_VERSION}_linux_amd64.zip && \
	sudo mv consul /usr/bin/consul
	consul --version
	sudo cp master/*.json /etc/consul.d/
	sudo mkdir -p /var/log/consul
	sudo chown -R consul:consul /var/log/consul
	sudo systemctl restart consul
	sudo systemctl enable consul
