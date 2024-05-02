CLUSTER_NAME = my-argocluster
CONFIG_PATH = ./.kind/kind-config.yaml
KIND_IMAGE = kindest/node:v1.26.14
ARGO_WORKFLOWS_VERSION = 3.5.6

init:
	make kind-init
	make argo-init


cleanup:
	make kind-cleanup

install-kubectl:
	curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
	curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
	install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl


# KIND local cluster
kind-init:
	make kind-create-cluster
	make kind-context-cluster

kind-cleanup:
	make kind-cleanup-cluster

kind-create-cluster:
	kind create cluster --config $(CONFIG_PATH) --name $(CLUSTER_NAME) --image $(KIND_IMAGE)

kind-context-cluster:
	kubectl config use-context kind-$(CLUSTER_NAME)

kind-cleanup-cluster:
	kind delete cluster --name $(CLUSTER_NAME)


argo-init:
	kubectl create namespace argo
	kubectl apply -n argo -f https://github.com/argoproj/argo-workflows/releases/download/v$(ARGO_WORKFLOWS_VERSION)/quick-start-minimal.yaml
