# https://github.com/jetstack/cert-manager/issues/1255
kubectl label namespace cert-manager certmanager.k8s.io/disable-validation=true

kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v0.10.0/cert-manager.yaml

# Install the CustomResourceDefinition resources separately
kubectl apply -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.10/deploy/manifests/00-crds.yaml

# Create the namespace for cert-manager
kubectl create namespace cert-manager

# Label the cert-manager namespace to disable resource validation
kubectl label namespace cert-manager certmanager.k8s.io/disable-validation=true

# Add the Jetstack Helm repository
helm repo add jetstack https://charts.jetstack.io

# Update your local Helm chart repository cache
helm repo update

# Install the cert-manager Helm chart
# Default values from: https://docs.cert-manager.io/en/latest/tasks/issuing-certificates/ingress-shim.html
helm install --name cert-manager --namespace cert-manager --version v0.10.0 jetstack/cert-manager 
helm upgrade cert-manager --install jetstack/cert-manager --force --namespace cert-manager --version v0.10.0 --set ingressShim.defaultIssuerName=letsencrypt-prod --set ingressShim.defaultIssuerKind=ClusterIssuer 

kubectl apply -f ClusterIssuerProduction.yaml

--set webhook.enabled=false