minikube delete &&
minikube start --cpus=4 --memory="8g" --disk-size="40g" --addons="ingress" --driver="virtualbox" --network-plugin="cni" --extra-config="kubelet.network-plugin=cni" &&
minikube ssh -- sudo mount bpffs -t bpf /sys/fs/bpf &&
kubectl create -f https://raw.githubusercontent.com/cilium/cilium/v1.8/install/kubernetes/quick-install.yaml &&
kubectl apply -f config/vault/init-cm.yaml
