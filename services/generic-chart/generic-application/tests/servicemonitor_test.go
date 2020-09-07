package testing

import (
	"testing"

	monitoringv1 "github.com/coreos/prometheus-operator/pkg/apis/monitoring/v1"
	"github.com/gruntwork-io/terratest/modules/helm"
	terrak8s "github.com/gruntwork-io/terratest/modules/k8s"
	"github.com/stretchr/testify/require"
)

var smTemplates = []string{"templates/servicemonitor.yaml"}

// Test default values
func TestSMDefaults(t *testing.T) {
	// set variables just to pass other resources render
	options := &helm.Options{
		SetValues: map[string]string{
			"app.team":          team,
			"resources.enabled": "false",
		},
		KubectlOptions: &terrak8s.KubectlOptions{
			Namespace: namespace,
		},
	}

	// render template
	render := helm.RenderTemplate(t, options, helmChartPath, releaseName, []string{"templates/servicemonitor.yaml"})

	// Unmarshal result to k8s object
	sm := monitoringv1.ServiceMonitor{}
	helm.UnmarshalK8SYaml(t, render, &sm)

	require.Equal(t, releaseName, sm.ObjectMeta.Name, "Got unexpected name")
	require.Equal(t, namespace, sm.ObjectMeta.Namespace, "Got unexpected namespace")
	require.Equal(t, "/internal/metrics", sm.Spec.Endpoints[0].Path, "Got unexpected path")
	require.Equal(t, "15s", sm.Spec.Endpoints[0].Interval, "Got unexpected interval")
	require.ElementsMatch(t, []string{namespace}, sm.Spec.NamespaceSelector.MatchNames, "Got unexpected namespace selector")
	require.Equal(t, team, sm.ObjectMeta.Labels["prometheus.io/instance"], "Got unexpected namespace selector")
}

// Test failure when team not defined
func TestSMNoTeam(t *testing.T) {
	// set this variables just to pass other resources render
	options := &helm.Options{
		SetValues: map[string]string{
			"resources.enabled": "false",
		},
		KubectlOptions: &terrak8s.KubectlOptions{
			Namespace: namespace,
		},
	}

	_, err := helm.RenderTemplateE(t, options, helmChartPath, releaseName, smTemplates)

	require.Error(t, err, "Expected error")
}

// Test service monitor will not created if enabled set to false
func TestSMAbsent(t *testing.T) {
	options := &helm.Options{
		SetValues: map[string]string{
			"app.team":            team,
			"resources.enabled":   "false",
			"app.metrics.enabled": "false",
		},
		KubectlOptions: &terrak8s.KubectlOptions{
			Namespace: namespace,
		},
	}

	// render template
	_, err := helm.RenderTemplateE(t, options, helmChartPath, releaseName, smTemplates)

	require.Error(t, err, "Rendering should return error")
}
