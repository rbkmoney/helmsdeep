package testing

import (
	"fmt"
	"testing"

	"github.com/gruntwork-io/terratest/modules/helm"
	terrak8s "github.com/gruntwork-io/terratest/modules/k8s"
	"github.com/stretchr/testify/require"
	batchv1 "k8s.io/api/batch/v1"
)

var (
	hookTemplates = []string{"templates/hooks.yaml"}
)

// Test simple hook
func TestHooks(t *testing.T) {
	hookName := "test"
	hookJobName := fmt.Sprintf("%s-%s-hook", releaseName, hookName)
	commandBegin := "run"
	commandEnd := "something"
	envVarName := "ENV_VAR"
	envVarValue := "env-value"
	imageRepo := "docker-image"
	imageTag := "docker-tag"
	image := fmt.Sprintf("%s:%s", imageRepo, imageTag)
	options := &helm.Options{
		SetValues: map[string]string{
			"app.team":                  team,
			"resources.enabled":         "false",
			"hooks[0].name":             hookName,
			"hooks[0].image.repository": imageRepo,
			"hooks[0].image.tag":        imageTag,
			"hooks[0].command[0]":       commandBegin,
			"hooks[0].command[1]":       commandEnd,
			"hooks[0].env[0].name":      envVarName,
			"hooks[0].env[0].value":     envVarValue,
		},
		KubectlOptions: &terrak8s.KubectlOptions{
			Namespace: namespace,
		},
	}

	// render template
	render := helm.RenderTemplate(t, options, helmChartPath, releaseName, hookTemplates)

	// Unmarshal result to k8s object
	job := batchv1.Job{}
	helm.UnmarshalK8SYaml(t, render, &job)

	require.Equal(t, hookJobName, job.ObjectMeta.Name, "Got unexpected name")
	require.Equal(t, namespace, job.ObjectMeta.Namespace, "Got unexpected namespace")

	// check hook container
	require.Equal(t, hookJobName, job.Spec.Template.Spec.Containers[0].Name, "Got unexpected container name")
	require.Equal(t, image, job.Spec.Template.Spec.Containers[0].Image, "Got unexpected container name image")
	require.Equal(t, commandBegin, job.Spec.Template.Spec.Containers[0].Command[0], "Got unexpected container command")
	require.Equal(t, commandEnd, job.Spec.Template.Spec.Containers[0].Command[1], "Got unexpected container command")
	require.Equal(t, envVarName, job.Spec.Template.Spec.Containers[0].Env[0].Name, "Got unexpected container env var name")
	require.Equal(t, envVarValue, job.Spec.Template.Spec.Containers[0].Env[0].Value, "Got unexpected container env var value")

	// check default annotations values
	require.Equal(
		t,
		"pre-install,pre-upgrade",
		job.ObjectMeta.Annotations["helm.sh/hook"],
		"Got unexpected affinity topology key",
	)
	require.Equal(
		t,
		"1",
		job.ObjectMeta.Annotations["helm.sh/hook-weight"],
		"Got unexpected affinity topology key",
	)
	require.Equal(
		t,
		"hook-succeeded,before-hook-creation",
		job.ObjectMeta.Annotations["helm.sh/hook-delete-policy"],
		"Got unexpected affinity topology key",
	)
}

// Test case when we don't need PDB
func TestHooksAbsent(t *testing.T) {
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
	_, err := helm.RenderTemplateE(t, options, helmChartPath, releaseName, hookTemplates)

	require.Error(t, err, "Rendering should return error")
}

func TestHooksDefaultImage(t *testing.T) {
	hookName := "test"
	hookJobName := fmt.Sprintf("%s-%s-hook", releaseName, hookName)
	imageRepo := "docker-image"
	imageTag := "docker-tag"
	image := fmt.Sprintf("%s:%s", imageRepo, imageTag)
	options := &helm.Options{
		SetValues: map[string]string{
			"app.team":                team,
			"resources.enabled":       "false",
			"hooks[0].name":           hookName,
			"global.image.repository": imageRepo,
			"global.image.tag":        imageTag,
		},
		KubectlOptions: &terrak8s.KubectlOptions{
			Namespace: namespace,
		},
	}

	// render template
	render := helm.RenderTemplate(t, options, helmChartPath, releaseName, hookTemplates)

	// Unmarshal result to k8s object
	job := batchv1.Job{}
	helm.UnmarshalK8SYaml(t, render, &job)

	require.Equal(t, hookJobName, job.ObjectMeta.Name, "Got unexpected name")
	require.Equal(t, namespace, job.ObjectMeta.Namespace, "Got unexpected namespace")

	// check hook container
	require.Equal(t, hookJobName, job.Spec.Template.Spec.Containers[0].Name, "Got unexpected container name")
	require.Equal(t, image, job.Spec.Template.Spec.Containers[0].Image, "Got unexpected container name image")
}

func TestHooksEnv(t *testing.T) {
	hookName := "test"
	hookJobName := fmt.Sprintf("%s-%s-hook", releaseName, hookName)
	simpleEnvVarName := "SIMPLE_VAR"
	simpleEnvVarValue := "test value"
	templateEnvVarName := "TEMPLATE_VAR"
	templateEnvVarTemplate := "test.{{ .Release.Namespace }}.test"
	templateEnvVarValue := fmt.Sprintf("test.%s.test", namespace)
	envVarWithRefName := "REF_VAR"
	envVarWithRefValue := "status.hostIP"

	options := &helm.Options{
		SetValues: map[string]string{
			"app.team":                                     team,
			"resources.enabled":                            "false",
			"hooks[0].name":                                hookName,
			"hooks[0].env[0].name":                         simpleEnvVarName,
			"hooks[0].env[0].value":                        simpleEnvVarValue,
			"hooks[0].env[1].name":                         templateEnvVarName,
			"hooks[0].env[1].value":                        templateEnvVarTemplate,
			"hooks[0].env[2].name":                         envVarWithRefName,
			"hooks[0].env[2].valueFrom.fieldRef.fieldPath": envVarWithRefValue,
		},
		KubectlOptions: &terrak8s.KubectlOptions{
			Namespace: namespace,
		},
	}

	// render template
	render := helm.RenderTemplate(t, options, helmChartPath, releaseName, hookTemplates)

	// Unmarshal result to k8s object
	job := batchv1.Job{}
	helm.UnmarshalK8SYaml(t, render, &job)

	require.Equal(t, hookJobName, job.ObjectMeta.Name, "Got unexpected name")
	require.Equal(t, namespace, job.ObjectMeta.Namespace, "Got unexpected namespace")

	// check envs
	// check simple env variable
	require.Equal(
		t,
		simpleEnvVarName,
		job.Spec.Template.Spec.Containers[0].Env[0].Name,
		"Got unexpected env var name",
	)
	require.Equal(
		t,
		simpleEnvVarValue,
		job.Spec.Template.Spec.Containers[0].Env[0].Value,
		"Got unexpected env var value",
	)

	// check env with templating
	require.Equal(
		t,
		templateEnvVarName,
		job.Spec.Template.Spec.Containers[0].Env[1].Name,
		"Got unexpected env var name",
	)
	require.Equal(
		t,
		templateEnvVarValue,
		job.Spec.Template.Spec.Containers[0].Env[1].Value,
		"Got unexpected env var value",
	)

	// check env with ref
	require.Equal(
		t,
		envVarWithRefName,
		job.Spec.Template.Spec.Containers[0].Env[2].Name,
		"Got unexpected env var name",
	)
	require.Equal(
		t,
		envVarWithRefValue,
		job.Spec.Template.Spec.Containers[0].Env[2].ValueFrom.FieldRef.FieldPath,
		"Got unexpected env var value",
	)
}

func TestHooksImagePullSecrets(t *testing.T) {
	hookName := "test"
	hookJobName := fmt.Sprintf("%s-%s-hook", releaseName, hookName)
	secretName := "test-image-pull-secret"
	options := &helm.Options{
		SetValues: map[string]string{
			"app.team":                   team,
			"resources.enabled":          "false",
			"hooks[0].name":              hookName,
			"global.imagePullSecrets[0]": secretName,
		},
		KubectlOptions: &terrak8s.KubectlOptions{
			Namespace: namespace,
		},
	}

	// render template
	render := helm.RenderTemplate(t, options, helmChartPath, releaseName, hookTemplates)

	// Unmarshal result to k8s object
	job := batchv1.Job{}
	helm.UnmarshalK8SYaml(t, render, &job)

	require.Equal(t, hookJobName, job.ObjectMeta.Name, "Got unexpected name")
	require.Equal(t, namespace, job.ObjectMeta.Namespace, "Got unexpected namespace")

	// check pull secrets
	require.Equal(
		t,
		secretName,
		job.Spec.Template.Spec.ImagePullSecrets[0].Name,
		"Got unexpected image pull secret reference",
	)
}

func TestHooksImagePullSecretsOverride(t *testing.T) {
	hookName := "test"
	hookJobName := fmt.Sprintf("%s-%s-hook", releaseName, hookName)
	secretName := "test-image-pull-secret"
	options := &helm.Options{
		SetValues: map[string]string{
			"app.team":                     team,
			"resources.enabled":            "false",
			"global.imagePullSecrets[0]":   "wrong",
			"hooks[0].name":                hookName,
			"hooks[0].imagePullSecrets[0]": secretName,
		},
		KubectlOptions: &terrak8s.KubectlOptions{
			Namespace: namespace,
		},
	}

	// render template
	render := helm.RenderTemplate(t, options, helmChartPath, releaseName, hookTemplates)

	// Unmarshal result to k8s object
	job := batchv1.Job{}
	helm.UnmarshalK8SYaml(t, render, &job)

	require.Equal(t, hookJobName, job.ObjectMeta.Name, "Got unexpected name")
	require.Equal(t, namespace, job.ObjectMeta.Namespace, "Got unexpected namespace")

	// check pull secrets
	require.Equal(
		t,
		secretName,
		job.Spec.Template.Spec.ImagePullSecrets[0].Name,
		"Got unexpected image pull secret reference",
	)
}
