Helm Charts Repo
=========

В этом репозитории находятся экспериментальные чарты для ядерных сервисов
платформы RBK.money. Структура каталога следующая:

- services - чарты сервисов, по каталогу на сервис
- config - настройки чартов, по каталогу на сервис
- libraries - чарты вспомогательных библиотек, по каталогу на библиотеку
- docs - документация

Требования
----------

Для работы с сервисами требуется Helm 3.2.1 и [Helmfile v0.116.0](https://github.com/roboll/helmfile).
Для запуска всего стека рекомендуется выделить на minikube не менее **3 CPU, 8GB RAM, 30GB Disk**

Запуск
------
Для доступа к приватному docker registry необходимо создать secret:

```shell
$ kubectl create secret docker-registry dr2reg --docker-server=dr2.rbkmoney.com --docker-username=$USERNAME --docker-password=$PASSWORD

```
> !**NOTES** С драйвером hyperkit и реже с драйвером virtualbox бывают проблемы с доступами к ресурсам за VPN, где находится dr2 registry. В этом случае рекомендуется запускаться с драйвером docker:
` minikube start --driver=docker`

Для быстрой и автоматической инициализации Vault нужен configMap:
```
kubectl apply -f config/vault/init-cm.yaml
```

Добавление в minikube ingress
------------------------------

```shell
$ minikube addons enable ingress

```

Пример запуска сервисов:

```shell
$ helmfile sync
Building dependency release=zookeeper, chart=services/zookeeper
...
UPDATED RELEASES:
NAME         CHART                   VERSION
machinegun   ./services/machinegun     0.1.0
kafka        ./services/kafka         0.21.2
riak         ./services/riak           0.1.0
consul       ./services/consul         3.9.5
zookeeper    ./services/zookeeper      2.1.3
```

После этого можно убедиться, что запущенные сервисы живы. Например, проверим machinegun

```shell
$ helmfile --selector name=machinegun test
Testing machinegun
Pod machinegun-test-connection pending
Pod machinegun-test-connection pending
Pod machinegun-test-connection succeeded
NAME: machinegun
LAST DEPLOYED: Sun May 1 13:22:20 2020
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE:     machinegun-test-connection
Last Started:   Sun May 1 13:27:14 2020
Last Completed: Sun May 1 13:27:18 2020
Phase:          Succeeded
NOTES:
You can use machinegun:8022 to connect to the machinegun woody interface.
```

Работа с Vault
----------
Волт запускается в dev режиме, то есть сразу инициированный и unseal. 
Референс для работы с секретами в [доке vault](https://www.hashicorp.com/blog/dynamic-database-credentials-with-vault-and-kubernetes/)

<details>
  <summary>Здесь немного комментов к тому, что происходит автоматом при запуске пода vault</summary>

```
# kubectl exec -ti vault-0 -- sh
```
```
#Включим движки:
vault auth enable kubernetes
vault secrets enable database

#Укажем адрес kube-api, к которому стоит обращаться для проверки токен сервис аккаунта приложения:
vault write auth/kubernetes/config \
       token_reviewer_jwt="$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" \
       kubernetes_host=https://${KUBERNETES_PORT_443_TCP_ADDR}:443 \
       kubernetes_ca_cert=@/var/run/secrets/kubernetes.io/serviceaccount/ca.crt

#Создадим роль, которая позволит перечисленным в `bound_service_account_names` сервисаккаунтам получать доступы к БД:

vault write auth/kubernetes/role/db-app \
    bound_service_account_names="*" \
    bound_service_account_namespaces=default \
    policies=db-app \
    ttl=1h

#теперь настраиваем подключение к постгресу:
vault write database/config/mydatabase \
    plugin_name=postgresql-database-plugin \
    allowed_roles="*" \
    connection_url="postgresql://{{username}}:{{password}}@postgres-postgresql.default:5432/?sslmode=disable" \
    username="postgres" \
    password="uw2dFhY9EP"

vault write database/roles/db-app \
    db_name=mydatabase \
    creation_statements="CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}'; \
        GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO \"{{name}}\";" \
    default_ttl="1h" \
    max_ttl="24h"
```
</details>

Чтобы зайти в вебку волта нужно получить себе новый токен:
```
kubectl exec vault-0 -- vault token create
```
включить портфорвард на локалхост
```
kubectl port-forward vault-0 8200:8200 &
```
и с полученым токеном идти в браузере на http://127.0.0.1:8200

Для того, чтобы приложение получило свои секретный логины-пароли к БД нужно добавить к описанию сервиса аннотации, [а тут смотреть целый манифест deployments](docs/service-with-vault-injected-creds-sample.yaml):
```
      annotations:
        vault.hashicorp.com/agent-inject: "true"
        vault.hashicorp.com/agent-inject-secret-db-creds: "database/creds/db-app"
        vault.hashicorp.com/agent-inject-template-db-creds: |
          {{- with secret "database/creds/db-app" -}}
          "db_connection": "postgresql://{{ .Data.username }}:{{ .Data.password }}@postgres-postgresql:5432/?sslmode=disable"
          {{- end }}
        vault.hashicorp.com/role: "db-app"
```
После этого в поде с сервисом будет лежать файл `/vault/secrets/db-creds` со строкой подключения к БД

Как включить сбор метрик
----------

requrements:
  - Service c именем порта api, на котором слушает http порт приложения
  - label
  ```          prometheusmetrics.enabled: "true" ```
  - Метрики приложения в формате prometheus должны отдаваться на локейшене /metrics
