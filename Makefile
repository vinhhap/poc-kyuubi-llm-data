NAMESPACE=spark-kyuubi

.PHONY: help
help: # Show help messages
	@grep -E '^[a-zA-Z0-9 -]+:.*#'  Makefile | sort | while read -r l; do printf "\033[1;32m$$(echo $$l | cut -f 1 -d':')\033[00m:$$(echo $$l | cut -f 2- -d'#')\n"; done

.PHONY: create-namespace
create-namespace: # Create the namespace for the project
	@echo "Creating namespace ${NAMESPACE}..."
	kubectl create namespace ${NAMESPACE}

.PHONY: add-helm-repos
add-helm-repos: # Add required Helm repositories
	@echo "Adding Helm repositories..."
	helm repo add bitnami https://charts.bitnami.com/bitnami
	helm repo add minio https://operator.min.io
	helm repo add opensearch https://opensearch-project.github.io/helm-charts
	helm repo add nessie https://charts.projectnessie.org
	helm repo add qdrant https://qdrant.github.io/qdrant-helm
	helm repo add superset https://apache.github.io/superset
	helm repo update

.PHONY: create-secrets
create-secrets: # Create Kubernetes secrets for the project (args: COMPONENT)
	@echo "Creating secrets in namespace ${NAMESPACE}..."
	kubectl apply -f $(COMPONENT)/secrets -n ${NAMESPACE}

.PHONY: install-minio
install-minio: # Install MinIO operator and tenant
	@echo "Installing MinIO operator and tenant in namespace ${NAMESPACE}..."
	helm install --namespace ${NAMESPACE} minio-operator minio/operator -f minio/operator_values.yaml
	helm install --namespace ${NAMESPACE} minio-tenant minio/tenant -f minio/tenant_values.yaml

.PHONY: install-postgres
install-postgres: # Install PostgreSQL
	@echo "Installing PostgreSQL in namespace ${NAMESPACE}..."
	helm install --namespace ${NAMESPACE} postgres bitnami/postgresql -f postgres/values.yaml

.PHONY: install-nessie
install-nessie: # Install Nessie
	@echo "Installing Nessie in namespace ${NAMESPACE}..."
	helm install --namespace ${NAMESPACE} nessie nessie/nessie -f nessie/values.yaml