package testing

import (
	"fmt"
	"strconv"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/helm"
	terrak8s "github.com/gruntwork-io/terratest/modules/k8s"
	"github.com/stretchr/testify/require"
	batchv1beta1 "k8s.io/api/batch/v1beta1"
	"k8s.io/apimachinery/pkg/api/resource"
)

var (
	cronjobTemplates = []string{"templates/cronjobs.yaml"}
	namespace        = "test-namespace"
	releaseName      = "test-release"
	helmChartPath    = ".."
	schedule         = "*/5 * * * *"
)

// Test default values
func TestCronjobsDefaults(t *testing.T) {
	options := &helm.Options{
		KubectlOptions: &terrak8s.KubectlOptions{
			Namespace: namespace,
		},
	}

	// render template
	_, err := helm.RenderTemplateE(t, options, helmChartPath, releaseName, cronjobTemplates)

	require.Error(t, err, "Rendering should return error")
}

// Test full defined values
func TestCronjobsFull(t *testing.T) {
	failedJobsHistoryLimit := "5"
	simpleEnvVarName := "SIMPLE_VAR"
	simpleEnvVarValue := "test value"
	templateEnvVarName := "TEMPLATE_VAR"
	templateEnvVarTemplate := "test.{{ .Release.Namespace }}.test"
	templateEnvVarValue := fmt.Sprintf("test.%s.test", namespace)
	envVarWithRefName := "REF_VAR"
	envVarWithRefValue := "status.hostIP"
	commandBegin := "run"
	commandEnd := "cron"
	cpu := "100m"
	cpuResource, _ := resource.ParseQuantity(cpu)
	memory := "128Mi"
	memoryResource, _ := resource.ParseQuantity(memory)

	options := &helm.Options{
		SetValues: map[string]string{
			"defaults.failedJobsHistoryLimit":             failedJobsHistoryLimit,
			"jobs[0].schedule":                            schedule,
			"jobs[0].resources.cpu":                       cpu,
			"jobs[0].resources.memory":                    memory,
			"jobs[0].env[0].name":                         simpleEnvVarName,
			"jobs[0].env[0].value":                        simpleEnvVarValue,
			"jobs[0].env[1].name":                         templateEnvVarName,
			"jobs[0].env[1].value":                        templateEnvVarTemplate,
			"jobs[0].env[2].name":                         envVarWithRefName,
			"jobs[0].env[2].valueFrom.fieldRef.fieldPath": envVarWithRefValue,
			"jobs[0].command[0]":                          commandBegin,
			"jobs[0].command[1]":                          commandEnd,
		},
		KubectlOptions: &terrak8s.KubectlOptions{
			Namespace: namespace,
		},
	}

	// render template
	render := helm.RenderTemplate(t, options, helmChartPath, releaseName, cronjobTemplates)

	// Unmarshal result to k8s object
	cronjob := batchv1beta1.CronJob{}
	helm.UnmarshalK8SYaml(t, render, &cronjob)

	require.Equal(t, namespace, cronjob.ObjectMeta.Namespace, "Got unexpected namespace")
	require.Equal(t, releaseName, cronjob.ObjectMeta.Name, "Got unexpected name")
	require.Equal(t, releaseName, cronjob.Spec.JobTemplate.Spec.Template.Spec.Containers[0].Name, "Got unexpected container name")
	require.Equal(t, schedule, cronjob.Spec.Schedule, "Got unexpected schedule")
	require.Equal(
		t,
		"3",
		strconv.Itoa(int(*cronjob.Spec.JobTemplate.Spec.BackoffLimit)),
		"Got unexpected backoff limit",
	)
	require.Equal(
		t,
		failedJobsHistoryLimit,
		strconv.Itoa(int(*cronjob.Spec.FailedJobsHistoryLimit)),
		"Got unexpected failed jobs history limit",
	)

	// check envs
	// check simple env variable
	require.Equal(
		t,
		simpleEnvVarName,
		cronjob.Spec.JobTemplate.Spec.Template.Spec.Containers[0].Env[0].Name,
		"Got unexpected env var name",
	)
	require.Equal(
		t,
		simpleEnvVarValue,
		cronjob.Spec.JobTemplate.Spec.Template.Spec.Containers[0].Env[0].Value,
		"Got unexpected env var value",
	)

	// check env with templating
	require.Equal(
		t,
		templateEnvVarName,
		cronjob.Spec.JobTemplate.Spec.Template.Spec.Containers[0].Env[1].Name,
		"Got unexpected env var name",
	)
	require.Equal(
		t,
		templateEnvVarValue,
		cronjob.Spec.JobTemplate.Spec.Template.Spec.Containers[0].Env[1].Value,
		"Got unexpected env var value",
	)

	// check env with ref
	require.Equal(
		t,
		envVarWithRefName,
		cronjob.Spec.JobTemplate.Spec.Template.Spec.Containers[0].Env[2].Name,
		"Got unexpected env var name",
	)
	require.Equal(
		t,
		envVarWithRefValue,
		cronjob.Spec.JobTemplate.Spec.Template.Spec.Containers[0].Env[2].ValueFrom.FieldRef.FieldPath,
		"Got unexpected env var value",
	)

	// check command
	require.Equal(
		t,
		commandBegin,
		cronjob.Spec.JobTemplate.Spec.Template.Spec.Containers[0].Command[0],
		"Got unexpected command",
	)
	require.Equal(
		t,
		commandEnd,
		cronjob.Spec.JobTemplate.Spec.Template.Spec.Containers[0].Command[1],
		"Got unexpected command",
	)

	// check resources
	// check cpu
	require.Equal(
		t,
		&cpuResource,
		cronjob.Spec.JobTemplate.Spec.Template.Spec.Containers[0].Resources.Requests.Cpu(),
		"Got unexpected cpu",
	)
	require.Equal(
		t,
		&cpuResource,
		cronjob.Spec.JobTemplate.Spec.Template.Spec.Containers[0].Resources.Limits.Cpu(),
		"Got unexpected cpu",
	)
	// check memory
	require.Equal(
		t,
		&memoryResource,
		cronjob.Spec.JobTemplate.Spec.Template.Spec.Containers[0].Resources.Requests.Memory(),
		"Got unexpected cpu",
	)
	require.Equal(
		t,
		&memoryResource,
		cronjob.Spec.JobTemplate.Spec.Template.Spec.Containers[0].Resources.Limits.Memory(),
		"Got unexpected cpu",
	)
}

// Test that generation failed without resources
func TestCronjobsWithoutResources(t *testing.T) {
	options := &helm.Options{
		SetValues: map[string]string{
			"jobs[0].schedule": schedule,
		},
		KubectlOptions: &terrak8s.KubectlOptions{
			Namespace: namespace,
		},
	}

	// render template
	_, err := helm.RenderTemplateE(t, options, helmChartPath, releaseName, cronjobTemplates)

	require.Error(t, err, "Error expected")
}

// Tetst case when we define job name
func TestCronjobsWithName(t *testing.T) {
	name := "job-name"
	cronjobname := fmt.Sprintf("%s-%s-job", releaseName, name)
	options := &helm.Options{
		SetValues: map[string]string{
			"defaults.resources.enabled": "false",
			"jobs[0].schedule":           schedule,
			"jobs[0].name":               name,
		},
		KubectlOptions: &terrak8s.KubectlOptions{
			Namespace: namespace,
		},
	}

	// render template
	render := helm.RenderTemplate(t, options, helmChartPath, releaseName, cronjobTemplates)

	// Unmarshal result to k8s object
	cronjob := batchv1beta1.CronJob{}
	helm.UnmarshalK8SYaml(t, render, &cronjob)

	require.Equal(t, namespace, cronjob.ObjectMeta.Namespace, "Got unexpected namespace")
	require.Equal(t, cronjobname, cronjob.ObjectMeta.Name, "Got unexpected name")
	require.Equal(t, cronjobname, cronjob.Spec.JobTemplate.Spec.Template.Spec.Containers[0].Name, "Got unexpected container name")
	require.Equal(t, schedule, cronjob.Spec.Schedule, "Got unexpected schedule")
}

// Tetst case when we define job name
func TestCronjobsWithNameAndJobsSuffix(t *testing.T) {
	name := "job-name"
	jobName := "test-release-job"
	cronjobname := fmt.Sprintf("%s-%s-job", strings.TrimRight(jobName, "-job"), name)
	options := &helm.Options{
		SetValues: map[string]string{
			"defaults.resources.enabled": "false",
			"jobs[0].schedule":           schedule,
			"jobs[0].name":               name,
		},
		KubectlOptions: &terrak8s.KubectlOptions{
			Namespace: namespace,
		},
	}

	// render template
	render := helm.RenderTemplate(t, options, helmChartPath, jobName, cronjobTemplates)

	// Unmarshal result to k8s object
	cronjob := batchv1beta1.CronJob{}
	helm.UnmarshalK8SYaml(t, render, &cronjob)

	require.Equal(t, namespace, cronjob.ObjectMeta.Namespace, "Got unexpected namespace")
	require.Equal(t, cronjobname, cronjob.ObjectMeta.Name, "Got unexpected name")
	require.Equal(t, cronjobname, cronjob.Spec.JobTemplate.Spec.Template.Spec.Containers[0].Name, "Got unexpected container name")
	require.Equal(t, schedule, cronjob.Spec.Schedule, "Got unexpected schedule")
}

// Tetst case when we define job name
func TestCronjobsActiveDeadlineSeconds(t *testing.T) {
	activeDeadlineSeconds := 60
	options := &helm.Options{
		SetValues: map[string]string{
			"defaults.resources.enabled":    "false",
			"jobs[0].activeDeadlineSeconds": strconv.Itoa(activeDeadlineSeconds),
			"jobs[0].schedule":              schedule,
		},
		KubectlOptions: &terrak8s.KubectlOptions{
			Namespace: namespace,
		},
	}

	// render template
	render := helm.RenderTemplate(t, options, helmChartPath, releaseName, cronjobTemplates)

	// Unmarshal result to k8s object
	cronjob := batchv1beta1.CronJob{}
	helm.UnmarshalK8SYaml(t, render, &cronjob)

	// check active deadline seconds
	require.Equal(t, activeDeadlineSeconds, int(*cronjob.Spec.JobTemplate.Spec.Template.Spec.ActiveDeadlineSeconds), "Got unexpeted value")

	// check that nothing is broken
	require.Equal(t, namespace, cronjob.ObjectMeta.Namespace, "Got unexpected namespace")
	require.Equal(t, releaseName, cronjob.ObjectMeta.Name, "Got unexpected name")
	require.Equal(t, releaseName, cronjob.Spec.JobTemplate.Spec.Template.Spec.Containers[0].Name, "Got unexpected container name")
	require.Equal(t, schedule, cronjob.Spec.Schedule, "Got unexpected schedule")
}

func TestCronjobsEnv(t *testing.T) {
	simpleEnvVarName := "SIMPLE_VAR"
	simpleEnvVarValue := "test value"
	templateEnvVarName := "TEMPLATE_VAR"
	templateEnvVarTemplate := "test.{{ .Release.Namespace }}.test"
	templateEnvVarValue := fmt.Sprintf("test.%s.test", namespace)
	envVarWithRefName := "REF_VAR"
	envVarWithRefValue := "status.hostIP"

	options := &helm.Options{
		SetValues: map[string]string{
			"defaults.resources.enabled":                  "false",
			"jobs[0].env[0].name":                         simpleEnvVarName,
			"jobs[0].env[0].value":                        simpleEnvVarValue,
			"jobs[0].env[1].name":                         templateEnvVarName,
			"jobs[0].env[1].value":                        templateEnvVarTemplate,
			"jobs[0].env[2].name":                         envVarWithRefName,
			"jobs[0].env[2].valueFrom.fieldRef.fieldPath": envVarWithRefValue,
		},
		KubectlOptions: &terrak8s.KubectlOptions{
			Namespace: namespace,
		},
	}

	// render template
	render := helm.RenderTemplate(t, options, helmChartPath, releaseName, cronjobTemplates)

	// Unmarshal result to k8s object
	cronjob := batchv1beta1.CronJob{}
	helm.UnmarshalK8SYaml(t, render, &cronjob)

	require.Equal(t, namespace, cronjob.ObjectMeta.Namespace, "Got unexpected namespace")
	require.Equal(t, releaseName, cronjob.ObjectMeta.Name, "Got unexpected name")

	// check envs
	// check simple env variable
	require.Equal(
		t,
		simpleEnvVarName,
		cronjob.Spec.JobTemplate.Spec.Template.Spec.Containers[0].Env[0].Name,
		"Got unexpected env var name",
	)
	require.Equal(
		t,
		simpleEnvVarValue,
		cronjob.Spec.JobTemplate.Spec.Template.Spec.Containers[0].Env[0].Value,
		"Got unexpected env var value",
	)

	// check env with templating
	require.Equal(
		t,
		templateEnvVarName,
		cronjob.Spec.JobTemplate.Spec.Template.Spec.Containers[0].Env[1].Name,
		"Got unexpected env var name",
	)
	require.Equal(
		t,
		templateEnvVarValue,
		cronjob.Spec.JobTemplate.Spec.Template.Spec.Containers[0].Env[1].Value,
		"Got unexpected env var value",
	)

	// check env with ref
	require.Equal(
		t,
		envVarWithRefName,
		cronjob.Spec.JobTemplate.Spec.Template.Spec.Containers[0].Env[2].Name,
		"Got unexpected env var name",
	)
	require.Equal(
		t,
		envVarWithRefValue,
		cronjob.Spec.JobTemplate.Spec.Template.Spec.Containers[0].Env[2].ValueFrom.FieldRef.FieldPath,
		"Got unexpected env var value",
	)
}

func TestCronjobsImagePullSecrets(t *testing.T) {
	name := "job-name"
	cronjobname := fmt.Sprintf("%s-%s-job", releaseName, name)
	secretName := "test-image-pull-secret"
	options := &helm.Options{
		SetValues: map[string]string{
			"defaults.resources.enabled": "false",
			"jobs[0].name":               name,
			"global.imagePullSecrets[0]": secretName,
		},
		KubectlOptions: &terrak8s.KubectlOptions{
			Namespace: namespace,
		},
	}

	// render template
	render := helm.RenderTemplate(t, options, helmChartPath, releaseName, cronjobTemplates)

	// Unmarshal result to k8s object
	cronjob := batchv1beta1.CronJob{}
	helm.UnmarshalK8SYaml(t, render, &cronjob)

	require.Equal(t, namespace, cronjob.ObjectMeta.Namespace, "Got unexpected namespace")
	require.Equal(t, cronjobname, cronjob.ObjectMeta.Name, "Got unexpected name")

	// check pull secrets
	require.Equal(
		t,
		secretName,
		cronjob.Spec.JobTemplate.Spec.Template.Spec.ImagePullSecrets[0].Name,
		"Got unexpected image pull secret reference",
	)
}

func TestCronjobsImagePullSecretsOverride(t *testing.T) {
	secretName := "test-image-pull-secret"
	options := &helm.Options{
		SetValues: map[string]string{
			"defaults.resources.enabled":  "false",
			"global.imagePullSecrets[0]":  "wrong",
			"jobs[0].imagePullSecrets[0]": secretName,
		},
		KubectlOptions: &terrak8s.KubectlOptions{
			Namespace: namespace,
		},
	}

	// render template
	render := helm.RenderTemplate(t, options, helmChartPath, releaseName, cronjobTemplates)

	// Unmarshal result to k8s object
	cronjob := batchv1beta1.CronJob{}
	helm.UnmarshalK8SYaml(t, render, &cronjob)

	require.Equal(t, namespace, cronjob.ObjectMeta.Namespace, "Got unexpected namespace")
	require.Equal(t, releaseName, cronjob.ObjectMeta.Name, "Got unexpected name")

	// check pull secrets
	require.Equal(
		t,
		secretName,
		cronjob.Spec.JobTemplate.Spec.Template.Spec.ImagePullSecrets[0].Name,
		"Got unexpected image pull secret reference",
	)
}

func TestCronjobsGlobalImage(t *testing.T) {
	name := "job-name"
	cronjobname := fmt.Sprintf("%s-%s-job", releaseName, name)
	imageRepo := "docker-image"
	imageTag := "docker-tag"
	image := fmt.Sprintf("%s:%s", imageRepo, imageTag)
	options := &helm.Options{
		SetValues: map[string]string{
			"defaults.resources.enabled": "false",
			"jobs[0].name":               name,
			"global.image.repository":    imageRepo,
			"global.image.tag":           imageTag,
		},
		KubectlOptions: &terrak8s.KubectlOptions{
			Namespace: namespace,
		},
	}

	// render template
	render := helm.RenderTemplate(t, options, helmChartPath, releaseName, cronjobTemplates)

	// Unmarshal result to k8s object
	cronjob := batchv1beta1.CronJob{}
	helm.UnmarshalK8SYaml(t, render, &cronjob)

	require.Equal(t, namespace, cronjob.ObjectMeta.Namespace, "Got unexpected namespace")
	require.Equal(t, cronjobname, cronjob.ObjectMeta.Name, "Got unexpected name")

	// check image
	require.Equal(
		t,
		image,
		cronjob.Spec.JobTemplate.Spec.Template.Spec.Containers[0].Image,
		"Got unexpected image",
	)
}

func TestCronjobsGlobalImageOverride(t *testing.T) {
	name := "job-name"
	cronjobname := fmt.Sprintf("%s-%s-job", releaseName, name)
	globalImageRepo := "global-docker-image"
	globalImageTag := "global-docker-tag"
	imageRepo := "docker-image"
	imageTag := "docker-tag"
	image := fmt.Sprintf("%s:%s", imageRepo, imageTag)
	options := &helm.Options{
		SetValues: map[string]string{
			"defaults.resources.enabled": "false",
			"global.image.repository":    globalImageRepo,
			"global.image.tag":           globalImageTag,
			"jobs[0].name":               name,
			"jobs[0].image.repository":   imageRepo,
			"jobs[0].image.tag":          imageTag,
		},
		KubectlOptions: &terrak8s.KubectlOptions{
			Namespace: namespace,
		},
	}

	// render template
	render := helm.RenderTemplate(t, options, helmChartPath, releaseName, cronjobTemplates)

	// Unmarshal result to k8s object
	cronjob := batchv1beta1.CronJob{}
	helm.UnmarshalK8SYaml(t, render, &cronjob)

	require.Equal(t, namespace, cronjob.ObjectMeta.Namespace, "Got unexpected namespace")
	require.Equal(t, cronjobname, cronjob.ObjectMeta.Name, "Got unexpected name")

	// check image
	require.Equal(
		t,
		image,
		cronjob.Spec.JobTemplate.Spec.Template.Spec.Containers[0].Image,
		"Got unexpected image",
	)
}
