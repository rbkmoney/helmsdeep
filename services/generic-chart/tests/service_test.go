package testing

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/helm"
	terrak8s "github.com/gruntwork-io/terratest/modules/k8s"
	"github.com/stretchr/testify/require"
	corev1 "k8s.io/api/core/v1"
)

var serviceTemplates = []string{"templates/service.yaml"}

// Test default values
func TestServiceDefaults(t *testing.T) {
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
	render := helm.RenderTemplate(t, options, helmChartPath, releaseName, serviceTemplates)

	// Unmarshal result to k8s object
	service := corev1.Service{}
	helm.UnmarshalK8SYaml(t, render, &service)

	require.Equal(t, namespace, service.ObjectMeta.Namespace, "Got unexpected namespace")
	require.Equal(t, releaseName, service.ObjectMeta.Name, "Got unexpected name")
	require.Equal(t, 80, int(service.Spec.Ports[0].Port), "Got unexpected port")
	require.Equal(t, "ClusterIP", string(service.Spec.Type), "Got unexpected service type")
	require.Equal(t, releaseName, service.Spec.Selector["app.kubernetes.io/name"], "Got unexpected selector")
}

// Test setting of service type to non-default value
func TestServiceType(t *testing.T) {
	serviceType := "NodePort"
	// set variables just to pass other resources render
	options := &helm.Options{
		SetValues: map[string]string{
			"app.team":          team,
			"resources.enabled": "false",
			"service.type":      serviceType,
		},
		KubectlOptions: &terrak8s.KubectlOptions{
			Namespace: namespace,
		},
	}

	// render template
	render := helm.RenderTemplate(t, options, helmChartPath, releaseName, serviceTemplates)

	// Unmarshal result to k8s object
	service := corev1.Service{}
	helm.UnmarshalK8SYaml(t, render, &service)

	// check that some others params was not broken
	require.Equal(t, namespace, service.ObjectMeta.Namespace, "Got unexpected namespace")
	require.Equal(t, releaseName, service.ObjectMeta.Name, "Got unexpected name")
	require.Equal(t, 80, int(service.Spec.Ports[0].Port), "Got unexpected port")
	require.Equal(t, map[string]string{"app.kubernetes.io/name": releaseName}, service.Spec.Selector, "Got unexpected selector")

	// check that correct service set
	require.Equal(t, serviceType, string(service.Spec.Type), "Got unexpected service type")
}

// Test setting of service type to non-default value
func TestServiceLoadBalancer(t *testing.T) {
	serviceType := "LoadBalancer"
	// set variables just to pass other resources render
	options := &helm.Options{
		SetValues: map[string]string{
			"app.team":          team,
			"resources.enabled": "false",
			"service.type":      serviceType,
		},
		KubectlOptions: &terrak8s.KubectlOptions{
			Namespace: namespace,
		},
	}

	// render template
	render := helm.RenderTemplate(t, options, helmChartPath, releaseName, serviceTemplates)

	// Unmarshal result to k8s object
	service := corev1.Service{}
	helm.UnmarshalK8SYaml(t, render, &service)

	// check that some others params was not broken
	require.Equal(t, namespace, service.ObjectMeta.Namespace, "Got unexpected namespace")
	require.Equal(t, releaseName, service.ObjectMeta.Name, "Got unexpected name")
	require.Equal(t, 80, int(service.Spec.Ports[0].Port), "Got unexpected port")
	require.Equal(t, map[string]string{"app.kubernetes.io/name": releaseName}, service.Spec.Selector, "Got unexpected selector")

	// check that correct service set
	require.Equal(t, serviceType, string(service.Spec.Type), "Got unexpected service type")

	// check azure lb annotation
	require.Equal(
		t,
		"true",
		service.ObjectMeta.Annotations["service.beta.kubernetes.io/azure-load-balancer-internal"],
		"Got unexpected service type",
	)
}
