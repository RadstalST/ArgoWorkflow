CLUSTER_NAME = my-argocluster
CONFIG_PATH = ./.kind/kind-config.yaml
KIND_IMAGE = kindest/node:v1.26.14
ARGO_WORKFLOWS_VERSION = 3.5.6
ARGO_NAMESPACE = argo
MANIFEST_PATH = ./kubenetes/argo-workflow/manifests/
.PHONY: init cleanup install-kubectl kind-init kind-cleanup kind-create-cluster kind-context-cluster kind-cleanup-cluster argo-init test start

## Init the project without cleaning up
init: kind-init argo-init 

## Initialize the project
reinit: kind-cleanup kind-init argo-init 

## Clean up the project
uninstall: kind-cleanup

## Install kubectl
install-kubectl:
	curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
	curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
	install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

## Initialize KIND local cluster
kind-init: kind-create-cluster kind-context-cluster

## Clean up KIND local cluster
kind-cleanup: kind-cleanup-cluster

## Create KIND local cluster
kind-create-cluster:
	kind create cluster --config $(CONFIG_PATH) --name $(CLUSTER_NAME) --image $(KIND_IMAGE)


## Set KIND local cluster as the current context
kind-context-cluster:
	kubectl config use-context kind-$(CLUSTER_NAME)
	

## Clean up KIND local cluster
kind-cleanup-cluster:
	kind delete cluster --name $(CLUSTER_NAME)

## Initialize Argo workflows
argo-init:
	kubectl create namespace $(ARGO_NAMESPACE)
	kubectl config set-context --current --namespace=$(ARGO_NAMESPACE)
	kubectl apply -n $(ARGO_NAMESPACE) -f https://github.com/argoproj/argo-workflows/releases/download/v$(ARGO_WORKFLOWS_VERSION)/quick-start-minimal.yaml
	kubectl apply --recursive -f $(MANIFEST_PATH) -n $(ARGO_NAMESPACE)
	

# ## Run tests
test:
	kubectl apply --recursive -f $(MANIFEST_PATH) -n $(ARGO_NAMESPACE)
	
argo-get-admin-token:
	
	export ARGO_TOKEN="Bearer $$(kubectl get secret admin.service-account-token -n $(ARGO_NAMESPACE) -o=jsonpath='{.data.token}' | base64 --decode)"; \
	echo $$ARGO_TOKEN
