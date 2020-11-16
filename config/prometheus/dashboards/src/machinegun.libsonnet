local grafana = import 'grafonnet-lib/grafonnet/grafana.libsonnet';
local graphPanel = grafana.graphPanel;
local prometheus = grafana.prometheus;

local percentileColors = {
  'p50': 'dark-red',
  'p95': 'yellow',
  'p99': 'green',
};

{
  timersLifecyclePanel(datasource)::
    graphPanel.new(
      title='Timers Lifecycle',
      datasource=datasource,
      bars=true,
      lines=false,
      stack=true,
      min=0,
    )
    .addTargets([
      prometheus.target(
        expr='sum by (change)(irate(mg_timer_lifecycle_changes_total{namespace="$namespace", exported_namespace="$mg_namespace"}[$interval]))',
        legendFormat='{{change}}',
      ),
    ]),

  machinesLifecyclePanel(datasource)::
    graphPanel.new(
      title='Machines Lifecycle',
      datasource=datasource,
      bars=true,
      lines=false,
      stack=true,
      min=0,
    )
    .addTargets([
      prometheus.target(
        expr='sum by (change)(irate(mg_machine_lifecycle_changes_total{namespace="$namespace", exported_namespace="$mg_namespace"}[$interval]))',
        legendFormat='{{change}}',
      ),
    ]),

  machinesImpactPanel(datasource)::
    graphPanel.new(
      title='Machines Process Impact',
      datasource=datasource,
      bars=true,
      lines=false,
      stack=true,
      min=0,
    )
    .addTargets([
      prometheus.target(
        expr='sum by (impact)(irate(mg_machine_processing_changes_total{namespace="$namespace", exported_namespace="$mg_namespace", change="started"}[$interval]))',
        legendFormat='{{impact}}',
      ),
    ]),

  machinesStartQueueUsagePanel(datasource)::
    graphPanel.new(
      title='Machines Start Queue Usage',
      datasource=datasource,
      bars=false,
      lines=false,
      points=true,
      pointradius=2,
      min=0,
      aliasColors=percentileColors,
    )
    .addTargets([
      prometheus.target(
        expr='histogram_quantile(0.5, sum by (le)(mg_worker_action_queue_usage_bucket{namespace="$namespace", exported_namespace="$mg_namespace"}))',
        legendFormat='p50',
      ),
      prometheus.target(
        expr='histogram_quantile(0.95, sum by (le)(mg_worker_action_queue_usage_bucket{namespace="$namespace", exported_namespace="$mg_namespace"}))',
        legendFormat='p95',
      ),
      prometheus.target(
        expr='histogram_quantile(0.99, sum by (le)(mg_worker_action_queue_usage_bucket{namespace="$namespace", exported_namespace="$mg_namespace"}))',
        legendFormat='p99',
      ),
    ]),

  schedulerChangesPanel(datasource)::
    graphPanel.new(
      title='Tasks',
      datasource=datasource,
      bars=true,
      lines=false,
      stack=true,
      min=0,
    )
    .addTargets([
      prometheus.target(
        expr='sum by (change)(irate(mg_scheduler_task_changes_total{namespace="$namespace", exported_namespace="$mg_namespace", name="$scheduler"}[$interval]))',
        legendFormat='{{change}}',
      ),
    ]),

  schedulerQuotaPanel(datasource)::
    graphPanel.new(
      title='Quota Usage',
      datasource=datasource,
      bars=true,
      lines=false,
      stack=true,
      min=0,
    )
    .addTargets([
      prometheus.target(
        expr='sum by (status)(mg_scheduler_task_quota_usage{namespace="$namespace", exported_namespace="$mg_namespace", name="$scheduler"})',
        legendFormat='{{status}}',
      ),
    ])
    .addSeriesOverride({
      alias: 'reserved',
      bars: false,
      fill: 0,
      lines: true,
      linewidth: 2,
      color: '#890f02',
      zindex: 3,
    })
    .addSeriesOverride({
      alias: 'active',
      color: '#3f6833',
    })
    .addSeriesOverride({
      alias: 'waiting',
      color: '#eab839',
    }),

  schedulerTaskDelayPanel(datasource)::
    graphPanel.new(
      title='Task Delay',
      datasource=datasource,
      bars=false,
      lines=false,
      points=true,
      pointradius=2,
      min=0,
      format='s',
      aliasColors=percentileColors,
    )
    .addTargets([
      prometheus.target(
        expr='histogram_quantile(0.5, sum by (le)(mg_scheduler_task_processing_delay_seconds_bucket{namespace="$namespace", exported_namespace="$mg_namespace", name="$scheduler"}))',
        legendFormat='p50',
      ),
      prometheus.target(
        expr='histogram_quantile(0.95, sum by (le)(mg_scheduler_task_processing_delay_seconds_bucket{namespace="$namespace", exported_namespace="$mg_namespace", name="$scheduler"}))',
        legendFormat='p95',
      ),
      prometheus.target(
        expr='histogram_quantile(0.99, sum by (le)(mg_scheduler_task_processing_delay_seconds_bucket{namespace="$namespace", exported_namespace="$mg_namespace", name="$scheduler"}))',
        legendFormat='p99',
      ),
    ]),

  schedulerScanDelayPanel(datasource)::
    graphPanel.new(
      title='Scan Delay',
      datasource=datasource,
      bars=false,
      lines=false,
      points=true,
      pointradius=2,
      min=0,
      format='s',
      aliasColors=percentileColors,
    )
    .addTargets([
      prometheus.target(
        expr='histogram_quantile(0.5, sum by (le)(mg_scheduler_scan_delay_seconds_bucket{namespace="$namespace", exported_namespace="$mg_namespace", name="$scheduler"}))',
        legendFormat='p50',
      ),
      prometheus.target(
        expr='histogram_quantile(0.95, sum by (le)(mg_scheduler_scan_delay_seconds_bucket{namespace="$namespace", exported_namespace="$mg_namespace", name="$scheduler"}))',
        legendFormat='p95',
      ),
      prometheus.target(
        expr='histogram_quantile(0.99, sum by (le)(mg_scheduler_scan_delay_seconds_bucket{namespace="$namespace", exported_namespace="$mg_namespace", name="$scheduler"}))',
        legendFormat='p99',
      ),
    ]),

  schedulerScanDurationPanel(datasource)::
    graphPanel.new(
      title='Scan Duration',
      datasource=datasource,
      bars=false,
      lines=false,
      points=true,
      pointradius=2,
      min=0,
      format='s',
      aliasColors=percentileColors,
    )
    .addTargets([
      prometheus.target(
        expr='histogram_quantile(0.5, sum by (le)(mg_scheduler_scan_duration_seconds_bucket{namespace="$namespace", exported_namespace="$mg_namespace", name="$scheduler"}))',
        legendFormat='p50',
      ),
      prometheus.target(
        expr='histogram_quantile(0.95, sum by (le)(mg_scheduler_scan_duration_seconds_bucket{namespace="$namespace", exported_namespace="$mg_namespace", name="$scheduler"}))',
        legendFormat='p95',
      ),
      prometheus.target(
        expr='histogram_quantile(0.99, sum by (le)(mg_scheduler_scan_duration_seconds_bucket{namespace="$namespace", exported_namespace="$mg_namespace", name="$scheduler"}))',
        legendFormat='p99',
      ),
    ]),

  schedulerTaskProcessingDurationPanel(datasource)::
    graphPanel.new(
      title='Task Processing Duration',
      datasource=datasource,
      bars=false,
      lines=false,
      points=true,
      pointradius=2,
      min=0,
      format='s',
      aliasColors=percentileColors,
    )
    .addTargets([
      prometheus.target(
        expr='histogram_quantile(0.5, sum by (le)(mg_scheduler_task_processing_duration_seconds_bucket{namespace="$namespace", exported_namespace="$mg_namespace", name="$scheduler"}))',
        legendFormat='p50',
      ),
      prometheus.target(
        expr='histogram_quantile(0.95, sum by (le)(mg_scheduler_task_processing_duration_seconds_bucket{namespace="$namespace", exported_namespace="$mg_namespace", name="$scheduler"}))',
        legendFormat='p95',
      ),
      prometheus.target(
        expr='histogram_quantile(0.99, sum by (le)(mg_scheduler_task_processing_duration_seconds_bucket{namespace="$namespace", exported_namespace="$mg_namespace", name="$scheduler"}))',
        legendFormat='p99',
      ),
    ]),

  storageChangesPanel(datasource)::
    graphPanel.new(
      title='`[[storage_operation]]` Total',
      datasource=datasource,
      bars=true,
      lines=false,
      stack=true,
      min=0,
    )
    .addTargets([
      prometheus.target(
        expr='sum by (change)(irate(mg_storage_operation_changes_total{change="finish", namespace="$namespace", exported_namespace="$mg_namespace", name="$storage", operation="$storage_operation"}[$interval]))',
        legendFormat='finished',
      ),
      prometheus.target(
        expr='sum by (change)(irate(mg_storage_operation_changes_total{change="finish", namespace="$namespace", exported_namespace="$mg_namespace", name="$storage", operation="$storage_operation"}[$interval])) - sum by (change)(irate(mg_storage_operation_changes_total{change="start", namespace="$namespace", exported_namespace="$mg_namespace", name="$storage", operation="$storage_operation"}[$interval]))',
        legendFormat='not finished',
      ),
    ])
    .addSeriesOverride({
      alias: 'finished',
      color: '#7eb26d',
    })
    .addSeriesOverride({
      alias: 'not finished',
      color: '#f2495c',
    }),

  storageDurationPanel(datasource)::
    graphPanel.new(
      title='`[[storage_operation]]` Duration',
      datasource=datasource,
      bars=false,
      lines=false,
      points=true,
      pointradius=2,
      min=0,
      format='s',
      aliasColors=percentileColors,
    )
    .addTargets([
      prometheus.target(
        expr='histogram_quantile(0.5, sum by (le)(mg_storage_operation_duration_seconds_bucket{namespace="$namespace", exported_namespace="$mg_namespace", name="$storage", operation="$storage_operation"}))',
        legendFormat='p50',
      ),
      prometheus.target(
        expr='histogram_quantile(0.95, sum by (le)(mg_storage_operation_duration_seconds_bucket{namespace="$namespace", exported_namespace="$mg_namespace", name="$storage", operation="$storage_operation"}))',
        legendFormat='p95',
      ),
      prometheus.target(
        expr='histogram_quantile(0.99, sum by (le)(mg_storage_operation_duration_seconds_bucket{namespace="$namespace", exported_namespace="$mg_namespace", name="$storage", operation="$storage_operation"}))',
        legendFormat='p99',
      ),
    ]),

  riakPoolConnectionsPanel(datasource)::
    graphPanel.new(
      title='Connections',
      datasource=datasource,
      bars=true,
      lines=false,
      stack=true,
      min=0,
    )
    .addTargets([
      prometheus.target(
        expr='sum(mg_riak_pool_connections_in_use{namespace="$namespace", exported_namespace="$mg_namespace", name="$riak_pool"})',
        legendFormat='in use',
      ),
      prometheus.target(
        expr='sum(mg_riak_pool_connections_free{namespace="$namespace", exported_namespace="$mg_namespace", name="$riak_pool"})',
        legendFormat='free',
      ),
      prometheus.target(
        expr='sum(mg_riak_pool_connections_limit{namespace="$namespace", exported_namespace="$mg_namespace", name="$riak_pool"})',
        legendFormat='limit',
      ),
    ])
    .addSeriesOverride({
      alias: 'in use',
      color: '#eab839',
    })
    .addSeriesOverride({
      alias: 'free',
      color: '#3f6833',
    })
    .addSeriesOverride({
      alias: 'limit',
      color: '#890f02',
      fill: 0,
      bars: false,
      lines: true,
      stack: false,
    }),

  riakPoolQueuePanel(datasource)::
    graphPanel.new(
      title='Pool Queue',
      datasource=datasource,
      bars=true,
      lines=false,
      stack=true,
      min=0,
    )
    .addTargets([
      prometheus.target(
        expr='sum(mg_riak_pool_queued_requests{namespace="$namespace", exported_namespace="$mg_namespace", name="$riak_pool"})',
        legendFormat='queued',
      ),
      prometheus.target(
        expr='sum(mg_riak_pool_queued_requests_limit{namespace="$namespace", exported_namespace="$mg_namespace", name="$riak_pool"})',
        legendFormat='limit',
      ),
    ])
    .addSeriesOverride({
      alias: 'queued',
      color: '#eab839',
    })
    .addSeriesOverride({
      alias: 'limit',
      color: '#890f02',
      fill: 0,
      bars: false,
      lines: true,
      stack: false,
    }),

  riakPoolInUsePerRequestPanel(datasource)::
    graphPanel.new(
      title='In Use Connections Per Request',
      datasource=datasource,
      bars=false,
      lines=false,
      points=true,
      pointradius=2,
      min=0,
      aliasColors=percentileColors,
    )
    .addTargets([
      prometheus.target(
        expr='histogram_quantile(0.5, sum by (le)(mg_riak_pool_connections_in_use_per_request_bucket{namespace="$namespace", exported_namespace="$mg_namespace", name="$riak_pool"}))',
        legendFormat='p50',
      ),
      prometheus.target(
        expr='histogram_quantile(0.95, sum by (le)(mg_riak_pool_connections_in_use_per_request_bucket{namespace="$namespace", exported_namespace="$mg_namespace", name="$riak_pool"}))',
        legendFormat='p95',
      ),
      prometheus.target(
        expr='histogram_quantile(0.99, sum by (le)(mg_riak_pool_connections_in_use_per_request_bucket{namespace="$namespace", exported_namespace="$mg_namespace", name="$riak_pool"}))',
        legendFormat='p99',
      ),
    ]),

  riakPoolFreePerRequestPanel(datasource)::
    graphPanel.new(
      title='Free Connections Per Request',
      datasource=datasource,
      bars=false,
      lines=false,
      points=true,
      pointradius=2,
      min=0,
      aliasColors=percentileColors,
    )
    .addTargets([
      prometheus.target(
        expr='histogram_quantile(0.5, sum by (le)(mg_riak_pool_connections_free_per_request_bucket{namespace="$namespace", exported_namespace="$mg_namespace", name="$riak_pool"}))',
        legendFormat='p50',
      ),
      prometheus.target(
        expr='histogram_quantile(0.95, sum by (le)(mg_riak_pool_connections_free_per_request_bucket{namespace="$namespace", exported_namespace="$mg_namespace", name="$riak_pool"}))',
        legendFormat='p95',
      ),
      prometheus.target(
        expr='histogram_quantile(0.99, sum by (le)(mg_riak_pool_connections_free_per_request_bucket{namespace="$namespace", exported_namespace="$mg_namespace", name="$riak_pool"}))',
        legendFormat='p99',
      ),
    ]),

  riakPoolQueuedPerRequestPanel(datasource)::
    graphPanel.new(
      title='Queued Requests Per Request',
      datasource=datasource,
      bars=false,
      lines=false,
      points=true,
      pointradius=2,
      min=0,
      aliasColors=percentileColors,
    )
    .addTargets([
      prometheus.target(
        expr='histogram_quantile(0.5, sum by (le)(mg_riak_pool_queued_requests_per_request_bucket{namespace="$namespace", exported_namespace="$mg_namespace", name="$riak_pool"}))',
        legendFormat='p50',
      ),
      prometheus.target(
        expr='histogram_quantile(0.95, sum by (le)(mg_riak_pool_queued_requests_per_request_bucket{namespace="$namespace", exported_namespace="$mg_namespace", name="$riak_pool"}))',
        legendFormat='p95',
      ),
      prometheus.target(
        expr='histogram_quantile(0.99, sum by (le)(mg_riak_pool_queued_requests_per_request_bucket{namespace="$namespace", exported_namespace="$mg_namespace", name="$riak_pool"}))',
        legendFormat='p99',
      ),
    ]),

  riakPoolNoFreeConnetionPanel(datasource)::
    graphPanel.new(
      title='No Free Connection Errors Number',
      datasource=datasource,
      bars=true,
      lines=false,
      stack=true,
      min=0,
    )
    .addTargets([
      prometheus.target(
        expr='sum(irate(mg_riak_pool_no_free_connection_errors_total{namespace="$namespace", exported_namespace="$mg_namespace", name="$riak_pool"}[$interval]))',
        legendFormat='total',
      ),
    ]),

  riakPoolConnectTimeoutPanel(datasource)::
    graphPanel.new(
      title='Connect Timeout Errors Number',
      datasource=datasource,
      bars=true,
      lines=false,
      stack=true,
      min=0,
    )
    .addTargets([
      prometheus.target(
        expr='sum(irate(mg_riak_pool_connect_timeout_errors_total{namespace="$namespace", exported_namespace="$mg_namespace", name="$riak_pool"}[$interval]))',
        legendFormat='total',
      ),
    ]),

  riakPoolQueueLimitPanel(datasource)::
    graphPanel.new(
      title='Queue Limit Reached Errors Number',
      datasource=datasource,
      bars=true,
      lines=false,
      stack=true,
      min=0,
    )
    .addTargets([
      prometheus.target(
        expr='sum(irate(mg_riak_pool_queue_limit_reached_errors_total{namespace="$namespace", exported_namespace="$mg_namespace", name="$riak_pool"}[$interval]))',
        legendFormat='total',
      ),
    ]),

  riakPoolKilledFreePanel(datasource)::
    graphPanel.new(
      title='Killed Free Connections Number',
      datasource=datasource,
      bars=true,
      lines=false,
      stack=true,
      min=0,
    )
    .addTargets([
      prometheus.target(
        expr='sum(irate(mg_riak_pool_killed_free_connections_total{namespace="$namespace", exported_namespace="$mg_namespace", name="$riak_pool"}[$interval]))',
        legendFormat='total',
      ),
    ]),

  riakPoolKilledInUsePanel(datasource)::
    graphPanel.new(
      title='Killed In Use Connections Number',
      datasource=datasource,
      bars=true,
      lines=false,
      stack=true,
      min=0,
    )
    .addTargets([
      prometheus.target(
        expr='sum(irate(mg_riak_pool_killed_in_use_connections_total{namespace="$namespace", exported_namespace="$mg_namespace", name="$riak_pool"}[$interval]))',
        legendFormat='total',
      ),
    ]),

  processingStartedPanel(datasource)::
    graphPanel.new(
      title='Machine Processing Started',
      datasource=datasource,
      bars=true,
      lines=false,
      stack=true,
      min=0,
    )
    .addTargets([
      prometheus.target(
        expr='sum(irate(mg_machine_processing_changes_total{change="started", namespace="$namespace", exported_namespace="$mg_namespace", impact="$processing_impact"}[$interval]))',
        legendFormat='total',
      ),
    ]),

  processingFinishedPanel(datasource)::
    graphPanel.new(
      title='Machine Processing Finished',
      datasource=datasource,
      bars=true,
      lines=false,
      stack=true,
      min=0,
    )
    .addTargets([
      prometheus.target(
        expr='sum(irate(mg_machine_processing_changes_total{change="finished", namespace="$namespace", exported_namespace="$mg_namespace", impact="$processing_impact"}[$interval]))',
        legendFormat='total',
      ),
    ]),

  processingDurationPanel(datasource)::
    graphPanel.new(
      title='Machine Processing Duration',
      datasource=datasource,
      bars=false,
      lines=false,
      points=true,
      pointradius=2,
      min=0,
      format='s',
      aliasColors=percentileColors,
    )
    .addTargets([
      prometheus.target(
        expr='histogram_quantile(0.5, sum by (le)(mg_machine_processing_duration_seconds_bucket{namespace="$namespace", exported_namespace="$mg_namespace", impact="$processing_impact"}))',
        legendFormat='p50',
      ),
      prometheus.target(
        expr='histogram_quantile(0.95, sum by (le)(mg_machine_processing_duration_seconds_bucket{namespace="$namespace", exported_namespace="$mg_namespace", impact="$processing_impact"}))',
        legendFormat='p95',
      ),
      prometheus.target(
        expr='histogram_quantile(0.99, sum by (le)(mg_machine_processing_duration_seconds_bucket{namespace="$namespace", exported_namespace="$mg_namespace", impact="$processing_impact"}))',
        legendFormat='p99',
      ),
    ]),

}
