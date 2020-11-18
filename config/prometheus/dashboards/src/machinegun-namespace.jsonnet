local grafana = import 'grafonnet-lib/grafonnet/grafana.libsonnet';
local dashboard = grafana.dashboard;
local template = grafana.template;
local row = grafana.row;
local erlang = import 'erlang.libsonnet';
local machinegun = import 'machinegun.libsonnet';

local datasource = 'Prometheus';

dashboard.new(
  title='Machinegun Namespace Overview',
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
    label='K8S Namespace',
    datasource=datasource,
    query='label_values(erlang_vm_process_count, namespace)',
    refresh='load',
  )
)
.addTemplate(
  template.new(
    name='mg_namespace',
    label='MG Namespace',
    datasource=datasource,
    current='invoice',
    query='label_values(mg_machine_lifecycle_changes_total{namespace="$namespace"}, exported_namespace)',
    refresh='load',
  )
)
.addTemplate(
  template.custom(
    name='service',
    label='Service',
    query='machinegun',
    current='machinegun',
    hide='all',
  )
)
.addTemplate(
  template.new(
    name='pod',
    label='Pod',
    datasource=datasource,
    query='label_values(erlang_vm_process_count{namespace="$namespace", service="$service"}, pod)',
    refresh='time',
    includeAll=true,
    hide='all',
    current='all',
  )
)
.addTemplate(
  template.new(
    name='scheduler',
    label='Scheduler Name',
    datasource=datasource,
    query='label_values(mg_scheduler_task_changes_total{namespace="$namespace", exported_namespace="$mg_namespace"}, name)',
    refresh='time',
    includeAll=true,
    hide='all',
    current='all',
  )
)
.addTemplate(
  template.new(
    name='storage',
    label='Storage Name',
    datasource=datasource,
    query='label_values(mg_storage_operation_changes_total{namespace="$namespace", exported_namespace="$mg_namespace"}, name)',
    refresh='time',
    includeAll=true,
    hide='all',
    current='all',
  )
)
.addTemplate(
  template.new(
    name='storage_operation',
    label='Storage Operation Name',
    datasource=datasource,
    query='label_values(mg_storage_operation_changes_total{namespace="$namespace", exported_namespace="$mg_namespace"}, operation)',
    refresh='time',
    includeAll=true,
    hide='all',
    current='all',
  )
)
.addTemplate(
  template.new(
    name='riak_pool',
    label='Riak Pool Name',
    datasource=datasource,
    query='label_values(mg_riak_pool_connections_in_use{namespace="$namespace", exported_namespace="$mg_namespace"}, name)',
    refresh='time',
    includeAll=true,
    hide='all',
    current='all',
  )
)
.addTemplate(
  template.new(
    name='processing_impact',
    label='Processing Impact',
    datasource=datasource,
    query='label_values(mg_machine_processing_changes_total{namespace="$namespace", exported_namespace="$mg_namespace"}, impact)',
    refresh='time',
    includeAll=true,
    hide='all',
    current='all',
  )
)
.addPanels([
  row.new(
    title='`[[mg_namespace]]` Overview',
    collapse=false,
  ) { gridPos: { h: 1, w: 24, x: 0, y: 0 } },
  // left column
  machinegun.timersLifecyclePanel(datasource) { gridPos: { h: 5, w: 12, x: 0, y: 1 } },
  machinegun.machinesImpactPanel(datasource) { gridPos: { h: 5, w: 12, x: 0, y: 1 } },
  // right column
  machinegun.machinesLifecyclePanel(datasource) { gridPos: { h: 5, w: 12, x: 12, y: 1 } },
  machinegun.machinesStartQueueUsagePanel(datasource) { gridPos: { h: 5, w: 12, x: 12, y: 1 } },
  row.new(
    title='BEAM on [[pod]]',
    repeat='pod',
    collapse=false,
  ) { gridPos: { h: 1, w: 24, x: 0, y: 6 } },
  // left column
  erlang.cpuPanel(datasource) { gridPos: { h: 5, w: 12, x: 0, y: 7 } },
  erlang.loadPanel(datasource) { gridPos: { h: 5, w: 12, x: 0, y: 7 } },
  erlang.gcPanel(datasource) { gridPos: { h: 5, w: 12, x: 0, y: 7 } },
  // right column
  erlang.memoryPanel(datasource) { gridPos: { h: 5, w: 12, x: 12, y: 7 } },
  erlang.ioPanel(datasource) { gridPos: { h: 5, w: 12, x: 12, y: 7 } },
  erlang.processesPanel(datasource) { gridPos: { h: 5, w: 12, x: 12, y: 7 } },
  row.new(
    title='`[[scheduler]]` Scheduler Overview',
    repeat='scheduler',
    collapse=true,
  )
  .addPanels([
    // left column
    machinegun.schedulerChangesPanel(datasource) { gridPos: { h: 5, w: 12, x: 0, y: 0 } },
    machinegun.schedulerScanDelayPanel(datasource) { gridPos: { h: 5, w: 12, x: 0, y: 0 } },
    machinegun.schedulerTaskDelayPanel(datasource) { gridPos: { h: 5, w: 12, x: 0, y: 0 } },
    // right column
    machinegun.schedulerQuotaPanel(datasource) { gridPos: { h: 5, w: 12, x: 12, y: 0 } },
    machinegun.schedulerScanDurationPanel(datasource) { gridPos: { h: 5, w: 12, x: 12, y: 0 } },
    machinegun.schedulerTaskProcessingDurationPanel(datasource) { gridPos: { h: 5, w: 12, x: 12, y: 0 } },
  ]) { gridPos: { h: 1, w: 24, x: 0, y: 8 } },
  row.new(
    title='`[[storage]]` Storage Overview',
    repeat='storage',
    collapse=true,
  )
  .addPanels([
    // left column
    machinegun.storageChangesPanel(datasource) { gridPos: { h: 5, w: 12, x: 0, y: 0 }, repeat: 'storage_operation' },
    // right column
    machinegun.storageDurationPanel(datasource) { gridPos: { h: 5, w: 12, x: 12, y: 0 }, repeat: 'storage_operation' },
  ]) { gridPos: { h: 1, w: 24, x: 0, y: 9 } },
  row.new(
    title='`[[riak_pool]]` Riak Pool Overview',
    repeat='riak_pool',
    collapse=true,
  )
  .addPanels([
    // left column
    machinegun.riakPoolConnectionsPanel(datasource) { gridPos: { h: 5, w: 12, x: 0, y: 0 } },
    machinegun.riakPoolInUsePerRequestPanel(datasource) { gridPos: { h: 5, w: 12, x: 0, y: 0 } },
    machinegun.riakPoolQueuedPerRequestPanel(datasource) { gridPos: { h: 5, w: 12, x: 0, y: 0 } },
    machinegun.riakPoolConnectTimeoutPanel(datasource) { gridPos: { h: 5, w: 12, x: 0, y: 0 } },
    machinegun.riakPoolKilledFreePanel(datasource) { gridPos: { h: 5, w: 12, x: 0, y: 0 } },
    // right column
    machinegun.riakPoolQueuePanel(datasource) { gridPos: { h: 5, w: 12, x: 12, y: 0 } },
    machinegun.riakPoolFreePerRequestPanel(datasource) { gridPos: { h: 5, w: 12, x: 12, y: 0 } },
    machinegun.riakPoolNoFreeConnetionPanel(datasource) { gridPos: { h: 5, w: 12, x: 12, y: 0 } },
    machinegun.riakPoolQueueLimitPanel(datasource) { gridPos: { h: 5, w: 12, x: 12, y: 0 } },
    machinegun.riakPoolKilledInUsePanel(datasource) { gridPos: { h: 5, w: 12, x: 12, y: 0 } },
  ]) { gridPos: { h: 1, w: 24, x: 0, y: 10 } },
  row.new(
    title='`[[processing_impact]]` Impact Processing',
    repeat='processing_impact',
    collapse=true,
  )
  .addPanels([
    // left column
    machinegun.processingStartedPanel(datasource) { gridPos: { h: 5, w: 12, x: 0, y: 0 } },
    machinegun.processingDurationPanel(datasource) { gridPos: { h: 5, w: 12, x: 0, y: 0 } },
    // right column
    machinegun.processingFinishedPanel(datasource) { gridPos: { h: 5, w: 12, x: 12, y: 0 } },
  ]) { gridPos: { h: 1, w: 24, x: 0, y: 12 } },
])
