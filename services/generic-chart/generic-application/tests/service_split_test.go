package testing

import (
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/helm"
	terrak8s "github.com/gruntwork-io/terratest/modules/k8s"
	"github.com/stretchr/testify/require"
	corev1 "k8s.io/api/core/v1"
)

var serviceSplitTemplates = []string{"templates/service-split.yaml"}

// Test default values
func TestServiceSplitDefaults(t *testing.T) {
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
	_, err := helm.RenderTemplateE(t, options, helmChartPath, releaseName, serviceSplitTemplates)

	require.Error(t, err, "Rendering should return error")
}

// Test setting of service type to non-default value
func TestServiceSplit(t *testing.T) {
	name := "Test"
	svcName := strings.ToLower(
		strings.Join(
			[]string{releaseName, name, "split"},
			"-",
		),
	)
	// set variables just to pass other resources render
	options := &helm.Options{
		SetValues: map[string]string{
			"app.team":              team,
			"resources.enabled":     "false",
			"ingresses[0].host":     "test.com",
			"ingresses[0].paths[0]": "/",
			"ingresses[0].name":     name,
			"ingresses[0].split":    "true",
		},
		KubectlOptions: &terrak8s.KubectlOptions{
			Namespace: namespace,
		},
	}

	// render template
	render := helm.RenderTemplate(t, options, helmChartPath, releaseName, serviceSplitTemplates)

	// Unmarshal result to k8s object
	service := corev1.Service{}
	helm.UnmarshalK8SYaml(t, render, &service)

	// check that some others params was not broken
	require.Equal(t, namespace, service.ObjectMeta.Namespace, "Got unexpected namespace")
	require.Equal(t, svcName, service.ObjectMeta.Name, "Got unexpected name")
	require.Equal(t, 80, int(service.Spec.Ports[0].Port), "Got unexpected port")
	require.Equal(t, map[string]string{"app.kubernetes.io/name": releaseName}, service.Spec.Selector, "Got unexpected selector")
}

// Test setting of service type to non-default value
func TestServiceSplitWithoutName(t *testing.T) {
	// set variables just to pass other resources render
	options := &helm.Options{
		SetValues: map[string]string{
			"app.team":              team,
			"resources.enabled":     "false",
			"ingresses[0].host":     "test.com",
			"ingresses[0].paths[0]": "/",
			"ingresses[0].split":    "true",
		},
		KubectlOptions: &terrak8s.KubectlOptions{
			Namespace: namespace,
		},
	}

	// render template
	_, err := helm.RenderTemplateE(t, options, helmChartPath, releaseName, serviceSplitTemplates)

	require.Error(t, err, "Rendering should return error")
}
