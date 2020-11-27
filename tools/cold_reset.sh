export MINIKUBE_MEMORY=${MINIKUBE_MEMORY:-8000}
export MINIKUBE_CPUS=${MINIKUBE_CPUS:-4}
export MINIKUBE_DISK_SIZE=${MINIKUBE_DISK_SIZE:-40g}
export MINIKUBE_DRIVER=${MINIKUBE_DRIVER:-virtualbox}
minikube delete &&
helm repo remove stable incubator bitnami hashicorp codecentric prometheus-community || echo "helm repos already deleted" &&
minikube start --addons="ingress" --network-plugin="cni" --extra-config="kubelet.network-plugin=cni" &&
minikube ssh -- sudo mount bpffs -t bpf /sys/fs/bpf &&
kubectl apply -f config/vault/init-cm.yaml
