local grafana = import 'grafonnet-lib/grafonnet/grafana.libsonnet';
local dashboard = grafana.dashboard;
local template = grafana.template;
local erlang = import 'erlang.libsonnet';

local datasource = 'Prometheus';

dashboard.new(
  title='Erlang Instance Overview',
  time_from='now-3h',
  time_to='now',
  refresh='30s',
  graphTooltip='shared_crosshair',
)
.addTemplate(
  template.interval(
    name='interval',
    label='Interval',
    query='1m,5m,10m,30m,1h,6h,12h,1d,7d,14d,30d',
    current='1m',
  )
)
.addTemplate(
  template.new(
    name='namespace',
    label='Namespace',
    datasource=datasource,
    query='label_values(erlang_vm_process_count, namespace)',
    refresh='load',
  )
)
.addTemplate(
  template.new(
    name='service',
    label='Service',
    datasource=datasource,
    query='label_values(erlang_vm_process_count{namespace="$namespace"}, service)',
    refresh='load',
  )
)
.addTemplate(
  template.new(
    name='pod',
    label='Pod',
    datasource=datasource,
    query='label_values(erlang_vm_process_count{namespace="$namespace", service="$service"}, pod)',
    refresh='time',
  )
)
.addPanels([
  // left column
  erlang.beamMemoryPanel(datasource) { gridPos: { h: 5, w: 12, x: 0, y: 0 } },
  erlang.cpuPanel(datasource) { gridPos: { h: 5, w: 12, x: 0, y: 0 } },
  erlang.loadPanel(datasource) { gridPos: { h: 5, w: 12, x: 0, y: 0 } },
  erlang.gcPanel(datasource) { gridPos: { h: 5, w: 12, x: 0, y: 0 } },
  // right column
  erlang.memoryPanel(datasource) { gridPos: { h: 5, w: 12, x: 12, y: 0 } },
  erlang.ioPanel(datasource) { gridPos: { h: 5, w: 12, x: 12, y: 0 } },
  erlang.processesPanel(datasource) { gridPos: { h: 5, w: 12, x: 12, y: 0 } },
])
