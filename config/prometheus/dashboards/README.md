Grafana Dashboards
=========

Наборы графиков, предзагруженные в графану при её инициализации.
Готовые дашборды находятся в директории `result`, их исходники в `src`.

Разработка нового дашборда
------

Необходимо иметь установленные `jsonnet` и `jsonnetfmt`.

Для создания нового дашборда достаточно создать файл с раширением `jsonnet` в директории `src`, в котором описать желаемое, аналогично прочим файлам в этой директории.

Для форматирования можно использовать команду `make format`

```shell
$ make format
jsonnetfmt --in-place -- src/erlang-instance.jsonnet
...
```

Затем, для генерации дашбордов из исходников можно воспользоваться командой `make generate`

```shell
$ make generate
jsonnet -o result/erlang-instance.json src/erlang-instance.jsonnet
...
```

Получившийся файл необходимо добавить в `config/prometheus/values.yaml.gotmpl`.
