# Do not re-download images
# authored by Dmitry Skokov <d.skokov@rbkmoney.com>
helmfile -f helmfile-infra.yaml delete \
&& helmfile delete \
&& sleep 5 \
&& kubectl delete deploy,rs,pvc,pv,svc,crd,ing,sts,job,cj,cm,secret,sa --all \
&& sleep 5 \
&& kubectl delete mutatingwebhookconfigurations,validatingwebhookconfigurations prometheus-prometheus-oper-admission || echo "prometheus webhooks already deleted" \
&& kubectl delete ns monitoring elastic-system || echo "namespaces not found" \
&& kubectl delete -f https://raw.githubusercontent.com/cilium/cilium/v1.8/install/kubernetes/quick-install.yaml || echo "cilium not found" \
&& sleep 30 \
&& kubectl apply -f https://raw.githubusercontent.com/cilium/cilium/v1.8/install/kubernetes/quick-install.yaml \
&& kubectl apply -f config/vault/init-cm.yaml
