minikube delete &&
helm repo remove stable incubator bitnami hashicorp codecentric prometheus-community cilium || echo "helm repos already deleted" &&i
minikube start --cpus=4 --memory="10g" --disk-size="40g" --addons="ingress" --driver="virtualbox" --network-plugin="cni" --extra-config="kubelet.network-plugin=cni" &&
minikube ssh -- sudo mount bpffs -t bpf /sys/fs/bpf &&
kubectl apply -f config/vault/init-cm.yaml
