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

Запуск
------
Для доступа к приватному docker registry необходимо создать secret:

```shell
$ kubectl create secret docker-registry dr2reg --docker-server=dr2.rbkmoney.com --docker-username=$USERNAME --docker-password=$PASSWORD

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
mg-riak      ./services/riak           0.1.0
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
