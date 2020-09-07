package testing

import (
	"fmt"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/helm"
	terrak8s "github.com/gruntwork-io/terratest/modules/k8s"
	"github.com/stretchr/testify/require"
	networkingv1beta1 "k8s.io/api/networking/v1beta1"
)

var (
	ingressesTemplates = []string{"templates/ingresses.yaml"}
)

// Test default values
func TestIngressesDefaults(t *testing.T) {
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
	_, err := helm.RenderTemplateE(t, options, helmChartPath, releaseName, ingressesTemplates)

	require.Error(t, err, "Rendering should return error")
}

// Test some ingress
func TestIngressesGeneration(t *testing.T) {
	host := "example.com"
	hostWithDashes := strings.ReplaceAll(host, ".", "-")
	ingressName := fmt.Sprintf("%s-%s", hostWithDashes, releaseName)
	firstPath := "/path"
	secondPath := "/second/path"
	// set variables just to pass other resources render
	options := &helm.Options{
		SetValues: map[string]string{
			"app.team":              team,
			"resources.enabled":     "false",
			"ingresses[0].host":     host,
			"ingresses[0].paths[0]": firstPath,
			"ingresses[0].paths[1]": secondPath,
			"linkerd.enabled":       "true",
		},
		KubectlOptions: &terrak8s.KubectlOptions{
			Namespace: namespace,
		},
	}

	// render template
	render := helm.RenderTemplate(t, options, helmChartPath, releaseName, ingressesTemplates)

	// Unmarshal result to k8s object
	ingress := networkingv1beta1.Ingress{}
	helm.UnmarshalK8SYaml(t, render, &ingress)

	require.Equal(t, ingressName, ingress.ObjectMeta.Name, "Got unexpected name")
	require.Equal(t, namespace, ingress.ObjectMeta.Namespace, "Got unexpected namespace")

	// check linkerd annotations
	require.Contains(
		t,
		ingress.ObjectMeta.Annotations["nginx.ingress.kubernetes.io/configuration-snippet"],
		"l5d-dst-override",
		"Got unexpected namespace",
	)

	// check certmanager annotations
	require.Equal(
		t,
		"letsencrypt",
		ingress.ObjectMeta.Annotations["cert-manager.io/cluster-issuer"],
		"Got unexpected annotation. Should not be specified",
	)

	// check TLS section
	require.Equal(t, host, ingress.Spec.TLS[0].Hosts[0], "Got unexpected hostname in TLS section")
	require.Equal(t, hostWithDashes, ingress.Spec.TLS[0].SecretName, "Got unexpected secret name in TLS section")

	// check rules
	require.Equal(t, host, ingress.Spec.Rules[0].Host, "Got unexpected hostname in rules section")
	require.Equal(t, firstPath, ingress.Spec.Rules[0].HTTP.Paths[0].Path, "Got unexpected path in rules section")
	require.Equal(t, releaseName, ingress.Spec.Rules[0].HTTP.Paths[0].Backend.ServiceName, "Got unexpected backend in rules section")
	require.Equal(t, secondPath, ingress.Spec.Rules[0].HTTP.Paths[1].Path, "Got unexpected path in rules section")
	require.Equal(t, releaseName, ingress.Spec.Rules[0].HTTP.Paths[1].Backend.ServiceName, "Got unexpected backend in rules section")
}

// Test some ingress without ssl
func TestIngressesSSLDisabled(t *testing.T) {
	host := "example.com"
	hostWithDashes := strings.ReplaceAll(host, ".", "-")
	ingressName := fmt.Sprintf("%s-%s", hostWithDashes, releaseName)
	path := "/"
	// set variables just to pass other resources render
	options := &helm.Options{
		SetValues: map[string]string{
			"app.team":              team,
			"resources.enabled":     "false",
			"ingresses[0].host":     host,
			"ingresses[0].paths[0]": path,
			"ingresses[0].ssl":      "disabled",
			"linkerd.enabled":       "false",
		},
		KubectlOptions: &terrak8s.KubectlOptions{
			Namespace: namespace,
		},
	}

	// render template
	render := helm.RenderTemplate(t, options, helmChartPath, releaseName, ingressesTemplates)

	// Unmarshal result to k8s object
	ingress := networkingv1beta1.Ingress{}
	helm.UnmarshalK8SYaml(t, render, &ingress)

	require.Equal(t, ingressName, ingress.ObjectMeta.Name, "Got unexpected name")
	require.Equal(t, namespace, ingress.ObjectMeta.Namespace, "Got unexpected namespace")

	// check that annotation empty
	require.Equal(
		t,
		"",
		ingress.ObjectMeta.Annotations["kubernetes.io/tls-acme"],
		"Got unexpected annotation value",
	)

	// check that we have tls unconfigured
	require.Equal(t, 0, len(ingress.Spec.TLS), "Got unexpected hostname in rules section")

	// check that rules was not broken
	require.Equal(t, host, ingress.Spec.Rules[0].Host, "Got unexpected hostname in rules section")
}

// Test some ingress
func TestIngressesLinkerdDisabled(t *testing.T) {
	host := "example.com"
	hostWithDashes := strings.ReplaceAll(host, ".", "-")
	ingressName := fmt.Sprintf("%s-%s", hostWithDashes, releaseName)
	path := "/"
	// set variables just to pass other resources render
	options := &helm.Options{
		SetValues: map[string]string{
			"app.team":              team,
			"resources.enabled":     "false",
			"ingresses[0].host":     host,
			"ingresses[0].paths[0]": path,
			"linkerd.enabled":       "false",
		},
		KubectlOptions: &terrak8s.KubectlOptions{
			Namespace: namespace,
		},
	}

	// render template
	render := helm.RenderTemplate(t, options, helmChartPath, releaseName, ingressesTemplates)

	// Unmarshal result to k8s object
	ingress := networkingv1beta1.Ingress{}
	helm.UnmarshalK8SYaml(t, render, &ingress)

	require.Equal(t, ingressName, ingress.ObjectMeta.Name, "Got unexpected name")
	require.Equal(t, namespace, ingress.ObjectMeta.Namespace, "Got unexpected namespace")

	// check linkerd annotations
	require.NotContains(
		t,
		ingress.ObjectMeta.Annotations["nginx.ingress.kubernetes.io/configuration-snippet"],
		"l5d-dst-override",
		"Got unexpected namespace",
	)

	// check that rules was not broken
	require.Equal(t, host, ingress.Spec.Rules[0].Host, "Got unexpected hostname in rules section")
}

// Test www.rbkmoney.com
func TestIngressesWWWRBKMONEYCOM(t *testing.T) {
	host := "www.rbkmoney.com"
	hostWithDashes := strings.ReplaceAll(host, ".", "-")
	ingressName := fmt.Sprintf("%s-%s", hostWithDashes, releaseName)
	path := "/"
	// set variables just to pass other resources render
	options := &helm.Options{
		SetValues: map[string]string{
			"app.team":              team,
			"resources.enabled":     "false",
			"ingresses[0].host":     host,
			"ingresses[0].paths[0]": path,
		},
		KubectlOptions: &terrak8s.KubectlOptions{
			Namespace: namespace,
		},
	}

	// render template
	render := helm.RenderTemplate(t, options, helmChartPath, releaseName, ingressesTemplates)

	// Unmarshal result to k8s object
	ingress := networkingv1beta1.Ingress{}
	helm.UnmarshalK8SYaml(t, render, &ingress)

	require.Equal(t, ingressName, ingress.ObjectMeta.Name, "Got unexpected name")
	require.Equal(t, namespace, ingress.ObjectMeta.Namespace, "Got unexpected namespace")

	// check certmanager annotations
	require.Equal(
		t,
		"",
		ingress.ObjectMeta.Annotations["cert-manager.io/cluster-issuer"],
		"Got unexpected annotation. Should not be specified",
	)

	// check linkerd annotations was not broken
	require.Contains(
		t,
		ingress.ObjectMeta.Annotations["nginx.ingress.kubernetes.io/configuration-snippet"],
		"l5d-dst-override",
		"Got unexpected namespace",
	)
	// check that rules was not broken
	require.Equal(t, host, ingress.Spec.Rules[0].Host, "Got unexpected hostname in rules section")
}

// Test www.rbkmoney.com
func TestIngressesHostTemplate(t *testing.T) {
	hostTemplate := "test.{{ .Release.Namespace }}.example.com" // tests failed if we start template with '{' symbol. terratest bug
	host := fmt.Sprintf("test.%s.example.com", namespace)
	hostWithDashes := strings.ReplaceAll(host, ".", "-")
	ingressName := fmt.Sprintf("%s-%s", hostWithDashes, releaseName)
	path := "/"
	// set variables just to pass other resources render
	options := &helm.Options{
		SetValues: map[string]string{
			"app.team":              team,
			"resources.enabled":     "false",
			"ingresses[0].host":     hostTemplate,
			"ingresses[0].paths[0]": path,
		},
		KubectlOptions: &terrak8s.KubectlOptions{
			Namespace: namespace,
		},
	}

	// render template
	render := helm.RenderTemplate(t, options, helmChartPath, releaseName, ingressesTemplates)

	// Unmarshal result to k8s object
	ingress := networkingv1beta1.Ingress{}
	helm.UnmarshalK8SYaml(t, render, &ingress)

	require.Equal(t, ingressName, ingress.ObjectMeta.Name, "Got unexpected name")
	require.Equal(t, namespace, ingress.ObjectMeta.Namespace, "Got unexpected namespace")

	// check that host was generated correctly
	require.Equal(t, host, ingress.Spec.Rules[0].Host, "Got unexpected hostname in rules section")
}

// Test canary weight
func TestIngressesCanaryWeight(t *testing.T) {
	host := "example.com"
	hostWithDashes := strings.ReplaceAll(host, ".", "-")
	ingressName := fmt.Sprintf("%s-%s-canary", hostWithDashes, releaseName)
	path := "/"
	canaryWeight := "10"
	// set variables just to pass other resources render
	options := &helm.Options{
		SetValues: map[string]string{
			"app.team":                   team,
			"resources.enabled":          "false",
			"ingresses[0].host":          host,
			"ingresses[0].paths[0]":      path,
			"ingresses[0].canary.weight": canaryWeight,
		},
		KubectlOptions: &terrak8s.KubectlOptions{
			Namespace: namespace,
		},
	}

	// render template
	render := helm.RenderTemplate(t, options, helmChartPath, releaseName, ingressesTemplates)

	// Unmarshal result to k8s object
	ingress := networkingv1beta1.Ingress{}
	helm.UnmarshalK8SYaml(t, render, &ingress)

	require.Equal(t, ingressName, ingress.ObjectMeta.Name, "Got unexpected name")
	require.Equal(t, namespace, ingress.ObjectMeta.Namespace, "Got unexpected namespace")

	// check cookie annotation
	require.Equal(
		t,
		canaryWeight,
		ingress.ObjectMeta.Annotations["nginx.ingress.kubernetes.io/canary-weight"],
		"Got unexpected canary weight",
	)

	// check that rules was not broken
	require.Equal(t, host, ingress.Spec.Rules[0].Host, "Got unexpected hostname in rules section")
}

// Test canary by cookie
func TestIngressesCanaryCookie(t *testing.T) {
	host := "example.com"
	hostWithDashes := strings.ReplaceAll(host, ".", "-")
	ingressName := fmt.Sprintf("%s-%s-canary", hostWithDashes, releaseName)
	path := "/"
	canaryCookie := "canary"
	// set variables just to pass other resources render
	options := &helm.Options{
		SetValues: map[string]string{
			"app.team":                   team,
			"resources.enabled":          "false",
			"ingresses[0].host":          host,
			"ingresses[0].paths[0]":      path,
			"ingresses[0].canary.cookie": canaryCookie,
		},
		KubectlOptions: &terrak8s.KubectlOptions{
			Namespace: namespace,
		},
	}

	// render template
	render := helm.RenderTemplate(t, options, helmChartPath, releaseName, ingressesTemplates)

	// Unmarshal result to k8s object
	ingress := networkingv1beta1.Ingress{}
	helm.UnmarshalK8SYaml(t, render, &ingress)

	require.Equal(t, ingressName, ingress.ObjectMeta.Name, "Got unexpected name")
	require.Equal(t, namespace, ingress.ObjectMeta.Namespace, "Got unexpected namespace")

	// check cookie annotation
	require.Equal(
		t,
		canaryCookie,
		ingress.ObjectMeta.Annotations["nginx.ingress.kubernetes.io/canary-by-cookie"],
		"Got unexpected canary weight",
	)

	// check that rules was not broken
	require.Equal(t, host, ingress.Spec.Rules[0].Host, "Got unexpected hostname in rules section")
}

// Test additinal annotations
func TestIngressesAdditionalAnnotation(t *testing.T) {
	host := "example.com"
	hostWithDashes := strings.ReplaceAll(host, ".", "-")
	ingressName := fmt.Sprintf("%s-%s", hostWithDashes, releaseName)
	path := "/"
	annotation := "test-annotation"
	annotationValue := "test annotation value"
	// set variables just to pass other resources render
	options := &helm.Options{
		SetValues: map[string]string{
			"app.team":              team,
			"resources.enabled":     "false",
			"ingresses[0].host":     host,
			"ingresses[0].paths[0]": path,
			fmt.Sprintf("ingresses[0].additionalAnnotations.%s", annotation): annotationValue,
		},
		KubectlOptions: &terrak8s.KubectlOptions{
			Namespace: namespace,
		},
	}

	// render template
	render := helm.RenderTemplate(t, options, helmChartPath, releaseName, ingressesTemplates)

	// Unmarshal result to k8s object
	ingress := networkingv1beta1.Ingress{}
	helm.UnmarshalK8SYaml(t, render, &ingress)

	require.Equal(t, ingressName, ingress.ObjectMeta.Name, "Got unexpected name")
	require.Equal(t, namespace, ingress.ObjectMeta.Namespace, "Got unexpected namespace")

	// check additional annotation
	require.Equal(
		t,
		annotationValue,
		ingress.ObjectMeta.Annotations[annotation],
		"Got unexpected annotation value",
	)

	// check that rules was not broken
	require.Equal(t, host, ingress.Spec.Rules[0].Host, "Got unexpected hostname in rules section")
}

// Test named ingress
func TestIngressesNamedIngress(t *testing.T) {
	host := "example.com"
	name := "Test"
	hostWithDashes := strings.ReplaceAll(host, ".", "-")
	ingressName := strings.ToLower(fmt.Sprintf("%s-%s-%s", hostWithDashes, name, releaseName))
	path := "/"
	// set variables just to pass other resources render
	options := &helm.Options{
		SetValues: map[string]string{
			"app.team":              team,
			"resources.enabled":     "false",
			"ingresses[0].host":     host,
			"ingresses[0].paths[0]": path,
			"ingresses[0].name":     name,
		},
		KubectlOptions: &terrak8s.KubectlOptions{
			Namespace: namespace,
		},
	}

	// render template
	render := helm.RenderTemplate(t, options, helmChartPath, releaseName, ingressesTemplates)

	// Unmarshal result to k8s object
	ingress := networkingv1beta1.Ingress{}
	helm.UnmarshalK8SYaml(t, render, &ingress)

	require.Equal(t, ingressName, ingress.ObjectMeta.Name, "Got unexpected name")
	require.Equal(t, namespace, ingress.ObjectMeta.Namespace, "Got unexpected namespace")

	// check that rules was not broken
	require.Equal(t, host, ingress.Spec.Rules[0].Host, "Got unexpected hostname in rules section")
}

// Test split ingress
func TestIngressesSplitIngress(t *testing.T) {
	host := "example.com"
	name := "Test"
	hostWithDashes := strings.ReplaceAll(host, ".", "-")
	ingressName := strings.ToLower(fmt.Sprintf("%s-%s-%s", hostWithDashes, name, releaseName))
	path := "/"
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
			"ingresses[0].host":     host,
			"ingresses[0].paths[0]": path,
			"ingresses[0].name":     name,
			"ingresses[0].split":    "true",
		},
		KubectlOptions: &terrak8s.KubectlOptions{
			Namespace: namespace,
		},
	}

	// render template
	render := helm.RenderTemplate(t, options, helmChartPath, releaseName, ingressesTemplates)

	// Unmarshal result to k8s object
	ingress := networkingv1beta1.Ingress{}
	helm.UnmarshalK8SYaml(t, render, &ingress)

	require.Equal(t, ingressName, ingress.ObjectMeta.Name, "Got unexpected name")
	require.Equal(t, namespace, ingress.ObjectMeta.Namespace, "Got unexpected namespace")

	// check that rules was not broken
	require.Equal(t, host, ingress.Spec.Rules[0].Host, "Got unexpected hostname in rules section")
	require.Equal(t, path, ingress.Spec.Rules[0].HTTP.Paths[0].Path, "Got unexpected path in rules section")
	require.Equal(t, svcName, ingress.Spec.Rules[0].HTTP.Paths[0].Backend.ServiceName, "Got unexpected backend in rules section")
}

func TestIngressesSplitIngressWithoutName(t *testing.T) {
	host := "example.com"
	path := "/"
	// set variables just to pass other resources render
	options := &helm.Options{
		SetValues: map[string]string{
			"app.team":              team,
			"resources.enabled":     "false",
			"ingresses[0].host":     host,
			"ingresses[0].paths[0]": path,
			"ingresses[0].split":    "true",
		},
		KubectlOptions: &terrak8s.KubectlOptions{
			Namespace: namespace,
		},
	}

	// render template
	_, err := helm.RenderTemplateE(t, options, helmChartPath, releaseName, ingressesTemplates)

	require.Error(t, err, "Rendering should return error")
}
