# Makefile

CONSULT_VERSION=1.9.0
CONSUL_LOG_DIR=/var/log/consul
CONSUL_CONF_DIR=/etc/consul.d

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
	sudo cp master/*.json ${CONSUL_CONF_DIR}/
	sudo mkdir -p ${CONSUL_LOG_DIR}
	sudo chown -R consul:consul ${CONSUL_LOG_DIR}
	sudo systemctl start consul
	sudo systemctl enable consul

update-config:  ## Update consul server configuration (server and service configs)
	sudo rm -f ${CONSUL_CONF_DIR}/*.json
	sudo cp master/*.json ${CONSUL_CONF_DIR}/
	sudo mkdir -p ${CONSUL_LOG_DIR}
	sudo chown -R consul:consul ${CONSUL_LOG_DIR}
	sudo systemctl restart consul

deploy-apps:  ## Deploy several applications
	docker run -d --restart=always -p=8001:3000 -p=18081:3001 -e UDP_ECHO_ENABLED=false -e HTTP_ECHO_ENABLED=false --name="consulapp1"      boeboe/wetty-echo-server:1.0.0-dbg
	docker run -d --restart=always -p=8002:3000 -p=18082:3003 -e TCP_ECHO_ENABLED=false -e UDP_ECHO_ENABLED=false  --name="consulapp2"      boeboe/wetty-echo-server:1.0.0-dbg
	docker run -d --restart=always -p=8003:3000 -p=19081:3003 -e TCP_ECHO_ENABLED=false -e UDP_ECHO_ENABLED=false  --name="consulmultiapp1" boeboe/wetty-echo-server:1.0.0-dbg
	docker run -d --restart=always -p=8004:3000 -p=19082:3003 -e TCP_ECHO_ENABLED=false -e UDP_ECHO_ENABLED=false  --name="consulmultiapp2" boeboe/wetty-echo-server:1.0.0-dbg
	docker run -d --restart=always -p=8005:3000 -p=19083:3003 -e TCP_ECHO_ENABLED=false -e UDP_ECHO_ENABLED=false  --name="consulmultiapp3" boeboe/wetty-echo-server:1.0.0-dbg

undeploy-apps:  ## Undeploy several applications
	docker stop consulapp1
	docker stop consulapp2
	docker stop consulmultiapp1
	docker stop consulmultiapp2
	docker stop consulmultiapp3
