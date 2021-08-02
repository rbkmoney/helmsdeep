# Do not re-download images
# authored by Dmitry Skokov <d.skokov@rbkmoney.com>
helmfile delete \
&& helm repo remove stable incubator bitnami hashicorp codecentric prometheus-community cilium rbkmoney || echo "helm repos already deleted" \
&& kubectl delete deploy,rs,pvc,pv,svc,crd,ing,sts,job,cj,cm,secret,sa --all \
&& minikube ssh -- sudo rm -rf /tmp/hostpath-provisioner/default \
&& kubectl delete mutatingwebhookconfigurations,validatingwebhookconfigurations prometheus-prometheus-oper-admission || echo "prometheus webhooks already deleted" \
&& kubectl delete ns monitoring elastic-system || echo "namespaces not found" \
