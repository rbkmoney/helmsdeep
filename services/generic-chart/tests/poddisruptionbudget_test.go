package testing

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/helm"
	terrak8s "github.com/gruntwork-io/terratest/modules/k8s"
	"github.com/stretchr/testify/require"
	policyv1beta1 "k8s.io/api/policy/v1beta1"
)

var pdbTemplates = []string{"templates/poddisruptionbudget.yaml"}

// Test default values
func TestPDBDefaults(t *testing.T) {
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
	render := helm.RenderTemplate(t, options, helmChartPath, releaseName, pdbTemplates)

	// Unmarshal result to k8s object
	pdb := policyv1beta1.PodDisruptionBudget{}
	helm.UnmarshalK8SYaml(t, render, &pdb)

	require.Equal(t, releaseName, pdb.ObjectMeta.Name, "Got unexpected name")
	require.Equal(t, namespace, pdb.ObjectMeta.Namespace, "Got unexpected namespace")
}

// Test case when we don't need PDB
func TestPDBAbsent(t *testing.T) {
	// set variables just to pass other resources render
	options := &helm.Options{
		SetValues: map[string]string{
			"app.team":          team,
			"resources.enabled": "false",
			"replicaCount":      "1",
		},
		KubectlOptions: &terrak8s.KubectlOptions{
			Namespace: namespace,
		},
	}

	// render template
	_, err := helm.RenderTemplateE(t, options, helmChartPath, releaseName, pdbTemplates)

	require.Error(t, err, "Rendering should return error")
}
