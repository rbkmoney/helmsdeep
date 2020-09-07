package testing

import (
	"fmt"
	"strconv"
	"testing"

	"github.com/gruntwork-io/terratest/modules/helm"
	terrak8s "github.com/gruntwork-io/terratest/modules/k8s"
	"github.com/stretchr/testify/require"
	appsv1 "k8s.io/api/apps/v1"
	corev1 "k8s.io/api/core/v1"
	"k8s.io/apimachinery/pkg/api/resource"
)

var (
	deploymentTemplates = []string{"templates/deployment.yaml"}
	affinityKey         = "kubernetes.io/hostname"
)

// Test default values
func TestDeploymentDefaults(t *testing.T) {
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
	render := helm.RenderTemplate(t, options, helmChartPath, releaseName, deploymentTemplates)

	// Unmarshal result to k8s object
	deployment := appsv1.Deployment{}
	helm.UnmarshalK8SYaml(t, render, &deployment)

	require.Equal(t, releaseName, deployment.ObjectMeta.Name, "Got unexpected name")
	require.Equal(t, namespace, deployment.ObjectMeta.Namespace, "Got unexpected namespace")

	// check linkerd annotation
	require.Equal(t, "enabled", deployment.Spec.Template.ObjectMeta.Annotations["linkerd.io/inject"], "Got unexpected annotation value")
	// check filebeat annotation
	require.Equal(
		t,
		"message",
		deployment.Spec.Template.ObjectMeta.Annotations["co.elastic.logs/processors.decode_json_fields.fields"],
		"Got unexpected annotation value",
	)

	// check some pod template value
	require.Equal(
		t,
		affinityKey,
		deployment.Spec.Template.Spec.Affinity.PodAntiAffinity.PreferredDuringSchedulingIgnoredDuringExecution[0].PodAffinityTerm.TopologyKey,
		"Got unexpected affinity topology key",
	)

	// check that env vars empty
	require.Equal(
		t,
		[]corev1.EnvVar(nil),
		deployment.Spec.Template.Spec.Containers[0].Env,
		"Got unexpected env var. Should be empty",
	)
}

// Test that render failed without team definition
func TestDeploymentWithoutTeam(t *testing.T) {
	// set variables just to pass other resources render
	options := &helm.Options{
		SetValues: map[string]string{
			"resources.enabled": "false",
		},
		KubectlOptions: &terrak8s.KubectlOptions{
			Namespace: namespace,
		},
	}

	_, err := helm.RenderTemplateE(t, options, helmChartPath, releaseName, deploymentTemplates)

	require.Error(t, err, "Expected error")
}

// Test linkerd annotation disappear
func TestDeploymentLinkerdAnnotation(t *testing.T) {
	// set variables just to pass other resources render
	options := &helm.Options{
		SetValues: map[string]string{
			"app.team":          team,
			"resources.enabled": "false",
			"linkerd.enabled":   "false",
		},
		KubectlOptions: &terrak8s.KubectlOptions{
			Namespace: namespace,
		},
	}

	// render template
	render := helm.RenderTemplate(t, options, helmChartPath, releaseName, deploymentTemplates)

	// Unmarshal result to k8s object
	deployment := appsv1.Deployment{}
	helm.UnmarshalK8SYaml(t, render, &deployment)

	require.Equal(t, releaseName, deployment.ObjectMeta.Name, "Got unexpected name")
	require.Equal(t, namespace, deployment.ObjectMeta.Namespace, "Got unexpected namespace") // render template

	// check linkerd annotation
	require.Equal(t, "", deployment.ObjectMeta.Annotations["linkerd.io/inject"], "Got unexpected annotation value, should be empty")
}

// Test that render failed without resources definition
func TestDeploymentWithoutResources(t *testing.T) {
	// set variables just to pass other resources render
	options := &helm.Options{
		SetValues: map[string]string{
			"app.team": team,
		},
		KubectlOptions: &terrak8s.KubectlOptions{
			Namespace: namespace,
		},
	}

	_, err := helm.RenderTemplateE(t, options, helmChartPath, releaseName, deploymentTemplates)

	require.Error(t, err, "Expected error")
}

// Test default values
func TestDeploymentResources(t *testing.T) {
	cpu := "100m"
	cpuResource, _ := resource.ParseQuantity(cpu)
	memory := "256Mi"
	memoryResource, _ := resource.ParseQuantity(memory)

	options := &helm.Options{
		SetValues: map[string]string{
			"app.team":         team,
			"resources.cpu":    cpu,
			"resources.memory": memory,
		},
		KubectlOptions: &terrak8s.KubectlOptions{
			Namespace: namespace,
		},
	}

	// render template
	render := helm.RenderTemplate(t, options, helmChartPath, releaseName, deploymentTemplates)

	// Unmarshal result to k8s object
	deployment := appsv1.Deployment{}
	helm.UnmarshalK8SYaml(t, render, &deployment)

	// common params
	require.Equal(t, releaseName, deployment.ObjectMeta.Name, "Got unexpected name")
	require.Equal(t, namespace, deployment.ObjectMeta.Namespace, "Got unexpected namespace")

	// check CPU requests
	require.Equal(
		t,
		&cpuResource,
		deployment.Spec.Template.Spec.Containers[0].Resources.Requests.Cpu(),
		"Got unexpected cpu",
	)

	// check memory requests and limits
	require.Equal(
		t,
		&memoryResource,
		deployment.Spec.Template.Spec.Containers[0].Resources.Requests.Memory(),
		"Got unexpected memory",
	)
	require.Equal(
		t,
		&memoryResource,
		deployment.Spec.Template.Spec.Containers[0].Resources.Limits.Memory(),
		"Got unexpected memory",
	)

	// check that rest of yaml was not broken
	require.Equal(
		t,
		affinityKey,
		deployment.Spec.Template.Spec.Affinity.PodAntiAffinity.PreferredDuringSchedulingIgnoredDuringExecution[0].PodAffinityTerm.TopologyKey,
		"Got unexpected affinity topology key",
	)
}

// Test that probes generates correctly
func TestDeploymentProbes(t *testing.T) {
	livenessPath := "/live"
	readinessPath := "/ready"
	initialDelaySeconds := "15"
	livenessInitialDelaySeconds := "20"
	periodSeconds := "5"
	failureThreshold := "3"

	// set variables just to pass other resources render
	options := &helm.Options{
		SetValues: map[string]string{
			"app.team":                       team,
			"resources.enabled":              "false",
			"app.probes.livenessPath":        livenessPath,
			"app.probes.readinessPath":       readinessPath,
			"app.probes.initialDelaySeconds": initialDelaySeconds,
			"app.probes.periodSeconds":       periodSeconds,
			"app.probes.failureThreshold":    failureThreshold,
		},
		KubectlOptions: &terrak8s.KubectlOptions{
			Namespace: namespace,
		},
	}

	// render template
	render := helm.RenderTemplate(t, options, helmChartPath, releaseName, deploymentTemplates)

	// Unmarshal result to k8s object
	deployment := appsv1.Deployment{}
	helm.UnmarshalK8SYaml(t, render, &deployment)

	// common params
	require.Equal(t, releaseName, deployment.ObjectMeta.Name, "Got unexpected name")
	require.Equal(t, namespace, deployment.ObjectMeta.Namespace, "Got unexpected namespace")

	// check probes paths
	require.Equal(
		t,
		readinessPath,
		deployment.Spec.Template.Spec.Containers[0].ReadinessProbe.HTTPGet.Path,
		"Got unexpected readiness probe path",
	)
	require.Equal(
		t,
		livenessPath,
		deployment.Spec.Template.Spec.Containers[0].LivenessProbe.HTTPGet.Path,
		"Got unexpected liveness probe path",
	)

	// check probes period seconds
	require.Equal(
		t,
		periodSeconds,
		strconv.Itoa(int(deployment.Spec.Template.Spec.Containers[0].ReadinessProbe.PeriodSeconds)),
		"Got unexpected readiness period seconds",
	)
	require.Equal(
		t,
		periodSeconds,
		strconv.Itoa(int(deployment.Spec.Template.Spec.Containers[0].LivenessProbe.PeriodSeconds)),
		"Got unexpected liveness period seconds",
	)

	// check probes failure threshold
	require.Equal(
		t,
		failureThreshold,
		strconv.Itoa(int(deployment.Spec.Template.Spec.Containers[0].ReadinessProbe.FailureThreshold)),
		"Got unexpected readiness failure threshold",
	)
	require.Equal(
		t,
		failureThreshold,
		strconv.Itoa(int(deployment.Spec.Template.Spec.Containers[0].LivenessProbe.FailureThreshold)),
		"Got unexpected liveness failure threshold",
	)

	// check probes initial delay
	require.Equal(
		t,
		initialDelaySeconds,
		strconv.Itoa(int(deployment.Spec.Template.Spec.Containers[0].ReadinessProbe.InitialDelaySeconds)),
		"Got unexpected readiness failure threshold",
	)
	require.Equal(
		t,
		livenessInitialDelaySeconds,
		strconv.Itoa(int(deployment.Spec.Template.Spec.Containers[0].LivenessProbe.InitialDelaySeconds)),
		"Got unexpected liveness failure threshold",
	)
}

// Test that env vars generates correctly
func TestDeploymentEnvs(t *testing.T) {
	simpleEnvVarName := "SIMPLE_VAR"
	simpleEnvVarValue := "test value"
	templateEnvVarName := "TEMPLATE_VAR"
	templateEnvVarTemplate := "test.{{ .Release.Namespace }}.test"
	templateEnvVarValue := fmt.Sprintf("test.%s.test", namespace)
	envVarWithRefName := "REF_VAR"
	envVarWithRefValue := "status.hostIP"

	options := &helm.Options{
		SetValues: map[string]string{
			"app.team":          team,
			"resources.enabled": "false",
			"app.env[0].name":   simpleEnvVarName,
			"app.env[0].value":  simpleEnvVarValue,
			"app.env[1].name":   templateEnvVarName,
			"app.env[1].value":  templateEnvVarTemplate,
			"app.env[2].name":   envVarWithRefName,
			"app.env[2].valueFrom.fieldRef.fieldPath": envVarWithRefValue,
		},
		KubectlOptions: &terrak8s.KubectlOptions{
			Namespace: namespace,
		},
	}

	// render template
	render := helm.RenderTemplate(t, options, helmChartPath, releaseName, deploymentTemplates)

	// Unmarshal result to k8s object
	deployment := appsv1.Deployment{}
	helm.UnmarshalK8SYaml(t, render, &deployment)

	// common params
	require.Equal(t, releaseName, deployment.ObjectMeta.Name, "Got unexpected name")
	require.Equal(t, namespace, deployment.ObjectMeta.Namespace, "Got unexpected namespace")

	// check simple env variable
	require.Equal(
		t,
		simpleEnvVarName,
		deployment.Spec.Template.Spec.Containers[0].Env[0].Name,
		"Got unexpected env var name",
	)
	require.Equal(
		t,
		simpleEnvVarValue,
		deployment.Spec.Template.Spec.Containers[0].Env[0].Value,
		"Got unexpected env var value",
	)

	// check env with templating
	require.Equal(
		t,
		templateEnvVarName,
		deployment.Spec.Template.Spec.Containers[0].Env[1].Name,
		"Got unexpected env var name",
	)
	require.Equal(
		t,
		templateEnvVarValue,
		deployment.Spec.Template.Spec.Containers[0].Env[1].Value,
		"Got unexpected env var value",
	)

	// check env with ref
	require.Equal(
		t,
		envVarWithRefName,
		deployment.Spec.Template.Spec.Containers[0].Env[2].Name,
		"Got unexpected env var name",
	)
	require.Equal(
		t,
		envVarWithRefValue,
		deployment.Spec.Template.Spec.Containers[0].Env[2].ValueFrom.FieldRef.FieldPath,
		"Got unexpected env var value",
	)

	// check that rest of yaml was not broken
	require.Equal(
		t,
		affinityKey,
		deployment.Spec.Template.Spec.Affinity.PodAntiAffinity.PreferredDuringSchedulingIgnoredDuringExecution[0].PodAffinityTerm.TopologyKey,
		"Got unexpected affinity topology key",
	)
}

// Test that env vars generates correctly when temp redis used
func TestDeploymentRedisTempEnvs(t *testing.T) {
	options := &helm.Options{
		SetValues: map[string]string{
			"app.team":          team,
			"resources.enabled": "false",
			"redis.temp":        "true",
		},
		KubectlOptions: &terrak8s.KubectlOptions{
			Namespace: namespace,
		},
	}

	// render template
	render := helm.RenderTemplate(t, options, helmChartPath, releaseName, deploymentTemplates)

	// Unmarshal result to k8s object
	deployment := appsv1.Deployment{}
	helm.UnmarshalK8SYaml(t, render, &deployment)

	// common params
	require.Equal(t, releaseName, deployment.ObjectMeta.Name, "Got unexpected name")
	require.Equal(t, namespace, deployment.ObjectMeta.Namespace, "Got unexpected namespace")

	// check simple env variable
	require.Subset(
		t,
		[]string{
			"REDIS",
			"REDIS_HOST",
		},
		[]string{
			deployment.Spec.Template.Spec.Containers[0].Env[0].Name,
		},
		"Got unexpected env var name",
	)

	// check that rest of yaml was not broken
	require.Equal(
		t,
		affinityKey,
		deployment.Spec.Template.Spec.Affinity.PodAntiAffinity.PreferredDuringSchedulingIgnoredDuringExecution[0].PodAffinityTerm.TopologyKey,
		"Got unexpected affinity topology key",
	)
}

// Test that env vars generates correctly
func TestDeploymentRedisAzureEnvs(t *testing.T) {
	redisURI := "azure-redis"
	options := &helm.Options{
		SetValues: map[string]string{
			"app.team":          team,
			"resources.enabled": "false",
			"redis.azure":       "true",
			"azureRedis.uri":    redisURI,
		},
		KubectlOptions: &terrak8s.KubectlOptions{
			Namespace: namespace,
		},
	}

	// render template
	render := helm.RenderTemplate(t, options, helmChartPath, releaseName, deploymentTemplates)

	// Unmarshal result to k8s object
	deployment := appsv1.Deployment{}
	helm.UnmarshalK8SYaml(t, render, &deployment)

	// common params
	require.Equal(t, releaseName, deployment.ObjectMeta.Name, "Got unexpected name")
	require.Equal(t, namespace, deployment.ObjectMeta.Namespace, "Got unexpected namespace")

	// check simple env variable
	require.Equal(
		t,
		"REDIS",
		deployment.Spec.Template.Spec.Containers[0].Env[0].Name,
		"Got unexpected env var name",
	)
	require.Equal(
		t,
		redisURI,
		deployment.Spec.Template.Spec.Containers[0].Env[0].Value,
		"Got unexpected env var secret ref",
	)

	// check that rest of yaml was not broken
	require.Equal(
		t,
		affinityKey,
		deployment.Spec.Template.Spec.Affinity.PodAntiAffinity.PreferredDuringSchedulingIgnoredDuringExecution[0].PodAffinityTerm.TopologyKey,
		"Got unexpected affinity topology key",
	)
}

func TestDeploymentLogsAnnotations(t *testing.T) {
	options := &helm.Options{
		SetValues: map[string]string{
			"app.team":          team,
			"resources.enabled": "false",
			"app.logs.json":     "false",
		},
		KubectlOptions: &terrak8s.KubectlOptions{
			Namespace: namespace,
		},
	}

	// render template
	render := helm.RenderTemplate(t, options, helmChartPath, releaseName, deploymentTemplates)

	// Unmarshal result to k8s object
	deployment := appsv1.Deployment{}
	helm.UnmarshalK8SYaml(t, render, &deployment)

	// common params
	require.Equal(t, releaseName, deployment.ObjectMeta.Name, "Got unexpected name")
	require.Equal(t, namespace, deployment.ObjectMeta.Namespace, "Got unexpected namespace")

	// check that annotation is absent
	require.Equal(
		t,
		"",
		deployment.Spec.Template.ObjectMeta.Annotations["co.elastic.logs/processors.decode_json_fields.fields"],
		"Got unexpected annotation value. Should be empty",
	)

	// check that rest of yaml was not broken
	require.Equal(
		t,
		affinityKey,
		deployment.Spec.Template.Spec.Affinity.PodAntiAffinity.PreferredDuringSchedulingIgnoredDuringExecution[0].PodAffinityTerm.TopologyKey,
		"Got unexpected affinity topology key",
	)
}

func TestDeploymentAdditionalAnnotations(t *testing.T) {
	options := &helm.Options{
		SetValues: map[string]string{
			"app.team":          team,
			"resources.enabled": "false",
			"app.additionalAnnotations.annotation/test": "enabled",
		},
		KubectlOptions: &terrak8s.KubectlOptions{
			Namespace: namespace,
		},
	}

	// render template
	render := helm.RenderTemplate(t, options, helmChartPath, releaseName, deploymentTemplates)

	// Unmarshal result to k8s object
	deployment := appsv1.Deployment{}
	helm.UnmarshalK8SYaml(t, render, &deployment)

	// common params
	require.Equal(t, releaseName, deployment.ObjectMeta.Name, "Got unexpected name")
	require.Equal(t, namespace, deployment.ObjectMeta.Namespace, "Got unexpected namespace")

	// check that annotation is absent
	require.Equal(
		t,
		"enabled",
		deployment.Spec.Template.ObjectMeta.Annotations["annotation/test"],
		"Got unexpected annotation value.",
	)

	// check that rest of yaml was not broken
	require.Equal(
		t,
		affinityKey,
		deployment.Spec.Template.Spec.Affinity.PodAntiAffinity.PreferredDuringSchedulingIgnoredDuringExecution[0].PodAffinityTerm.TopologyKey,
		"Got unexpected affinity topology key",
	)
}

func TestDeploymentImagePullSecrets(t *testing.T) {
	secretName := "test-image-pull-secret"
	options := &helm.Options{
		SetValues: map[string]string{
			"app.team":                   team,
			"resources.enabled":          "false",
			"global.imagePullSecrets[0]": secretName,
		},
		KubectlOptions: &terrak8s.KubectlOptions{
			Namespace: namespace,
		},
	}

	// render template
	render := helm.RenderTemplate(t, options, helmChartPath, releaseName, deploymentTemplates)

	// Unmarshal result to k8s object
	deployment := appsv1.Deployment{}
	helm.UnmarshalK8SYaml(t, render, &deployment)

	require.Equal(t, releaseName, deployment.ObjectMeta.Name, "Got unexpected name")
	require.Equal(t, namespace, deployment.ObjectMeta.Namespace, "Got unexpected namespace") // render template

	// check pull secrets
	require.Equal(
		t,
		secretName,
		deployment.Spec.Template.Spec.ImagePullSecrets[0].Name,
		"Got unexpected image pull secret reference",
	)

	// check that rest of yaml was not broken
	require.Equal(
		t,
		affinityKey,
		deployment.Spec.Template.Spec.Affinity.PodAntiAffinity.PreferredDuringSchedulingIgnoredDuringExecution[0].PodAffinityTerm.TopologyKey,
		"Got unexpected affinity topology key",
	)
}

// Test init containers
func TestInitContainers(t *testing.T) {
	initName := "init"
	initContainerName := fmt.Sprintf("%s-%s", releaseName, initName)
	commandBegin := "run"
	commandEnd := "something"
	envVarName := "ENV_VAR"
	envVarValue := "env-value"
	imageRepo := "docker-image"
	imageTag := "docker-tag"
	image := fmt.Sprintf("%s:%s", imageRepo, imageTag)
	options := &helm.Options{
		SetValues: map[string]string{
			"app.team":                           team,
			"resources.enabled":                  "false",
			"initContainers[0].name":             initName,
			"initContainers[0].image.repository": imageRepo,
			"initContainers[0].image.tag":        imageTag,
			"initContainers[0].command[0]":       commandBegin,
			"initContainers[0].command[1]":       commandEnd,
			"initContainers[0].env[0].name":      envVarName,
			"initContainers[0].env[0].value":     envVarValue,
		},
		KubectlOptions: &terrak8s.KubectlOptions{
			Namespace: namespace,
		},
	}

	// render template
	render := helm.RenderTemplate(t, options, helmChartPath, releaseName, deploymentTemplates)

	// Unmarshal result to k8s object
	deployment := appsv1.Deployment{}
	helm.UnmarshalK8SYaml(t, render, &deployment)

	require.Equal(t, releaseName, deployment.ObjectMeta.Name, "Got unexpected name")
	require.Equal(t, namespace, deployment.ObjectMeta.Namespace, "Got unexpected namespace") // render template

	// check init container
	require.Equal(t, initContainerName, deployment.Spec.Template.Spec.InitContainers[0].Name, "Got unexpected init container name")
	require.Equal(t, image, deployment.Spec.Template.Spec.InitContainers[0].Image, "Got unexpected init container name image")
	require.Equal(t, commandBegin, deployment.Spec.Template.Spec.InitContainers[0].Command[0], "Got unexpected init container command")
	require.Equal(t, commandEnd, deployment.Spec.Template.Spec.InitContainers[0].Command[1], "Got unexpected init container command")
	require.Equal(t, envVarName, deployment.Spec.Template.Spec.InitContainers[0].Env[0].Name, "Got unexpected init container env var name")
	require.Equal(t, envVarValue, deployment.Spec.Template.Spec.InitContainers[0].Env[0].Value, "Got unexpected init container env var value")

	// check that rest of yaml was not broken
	require.Equal(
		t,
		affinityKey,
		deployment.Spec.Template.Spec.Affinity.PodAntiAffinity.PreferredDuringSchedulingIgnoredDuringExecution[0].PodAffinityTerm.TopologyKey,
		"Got unexpected affinity topology key",
	)
}

func TestInitContainersDefaultImage(t *testing.T) {
	initName := "init"
	initContainerName := fmt.Sprintf("%s-%s", releaseName, initName)
	imageRepo := "docker-image"
	imageTag := "docker-tag"
	image := fmt.Sprintf("%s:%s", imageRepo, imageTag)
	options := &helm.Options{
		SetValues: map[string]string{
			"app.team":                team,
			"resources.enabled":       "false",
			"initContainers[0].name":  initName,
			"global.image.repository": imageRepo,
			"global.image.tag":        imageTag,
		},
		KubectlOptions: &terrak8s.KubectlOptions{
			Namespace: namespace,
		},
	}

	// render template
	render := helm.RenderTemplate(t, options, helmChartPath, releaseName, deploymentTemplates)

	// Unmarshal result to k8s object
	deployment := appsv1.Deployment{}
	helm.UnmarshalK8SYaml(t, render, &deployment)

	require.Equal(t, releaseName, deployment.ObjectMeta.Name, "Got unexpected name")
	require.Equal(t, namespace, deployment.ObjectMeta.Namespace, "Got unexpected namespace") // render template

	// check init container
	require.Equal(t, initContainerName, deployment.Spec.Template.Spec.InitContainers[0].Name, "Got unexpected init container name")
	require.Equal(t, image, deployment.Spec.Template.Spec.InitContainers[0].Image, "Got unexpected init container name image")

	// check that rest of yaml was not broken
	require.Equal(
		t,
		affinityKey,
		deployment.Spec.Template.Spec.Affinity.PodAntiAffinity.PreferredDuringSchedulingIgnoredDuringExecution[0].PodAffinityTerm.TopologyKey,
		"Got unexpected affinity topology key",
	)
}

func TestInitContainersEnv(t *testing.T) {
	initName := "init"
	initContainerName := fmt.Sprintf("%s-%s", releaseName, initName)
	simpleEnvVarName := "SIMPLE_VAR"
	simpleEnvVarValue := "test value"
	templateEnvVarName := "TEMPLATE_VAR"
	templateEnvVarTemplate := "test.{{ .Release.Namespace }}.test"
	templateEnvVarValue := fmt.Sprintf("test.%s.test", namespace)
	envVarWithRefName := "REF_VAR"
	envVarWithRefValue := "status.hostIP"

	options := &helm.Options{
		SetValues: map[string]string{
			"app.team":                                              team,
			"resources.enabled":                                     "false",
			"initContainers[0].name":                                initName,
			"initContainers[0].env[0].name":                         simpleEnvVarName,
			"initContainers[0].env[0].value":                        simpleEnvVarValue,
			"initContainers[0].env[1].name":                         templateEnvVarName,
			"initContainers[0].env[1].value":                        templateEnvVarTemplate,
			"initContainers[0].env[2].name":                         envVarWithRefName,
			"initContainers[0].env[2].valueFrom.fieldRef.fieldPath": envVarWithRefValue,
		},
		KubectlOptions: &terrak8s.KubectlOptions{
			Namespace: namespace,
		},
	}

	// render template
	render := helm.RenderTemplate(t, options, helmChartPath, releaseName, deploymentTemplates)

	// Unmarshal result to k8s object
	deployment := appsv1.Deployment{}
	helm.UnmarshalK8SYaml(t, render, &deployment)

	require.Equal(t, releaseName, deployment.ObjectMeta.Name, "Got unexpected name")
	require.Equal(t, namespace, deployment.ObjectMeta.Namespace, "Got unexpected namespace") // render template

	// check init container
	require.Equal(t, initContainerName, deployment.Spec.Template.Spec.InitContainers[0].Name, "Got unexpected init container name")

	// check envs
	// check simple env variable
	require.Equal(
		t,
		simpleEnvVarName,
		deployment.Spec.Template.Spec.InitContainers[0].Env[0].Name,
		"Got unexpected env var name",
	)
	require.Equal(
		t,
		simpleEnvVarValue,
		deployment.Spec.Template.Spec.InitContainers[0].Env[0].Value,
		"Got unexpected env var value",
	)

	// check env with templating
	require.Equal(
		t,
		templateEnvVarName,
		deployment.Spec.Template.Spec.InitContainers[0].Env[1].Name,
		"Got unexpected env var name",
	)
	require.Equal(
		t,
		templateEnvVarValue,
		deployment.Spec.Template.Spec.InitContainers[0].Env[1].Value,
		"Got unexpected env var value",
	)

	// check env with ref
	require.Equal(
		t,
		envVarWithRefName,
		deployment.Spec.Template.Spec.InitContainers[0].Env[2].Name,
		"Got unexpected env var name",
	)
	require.Equal(
		t,
		envVarWithRefValue,
		deployment.Spec.Template.Spec.InitContainers[0].Env[2].ValueFrom.FieldRef.FieldPath,
		"Got unexpected env var value",
	)

	// check that rest of yaml was not broken
	require.Equal(
		t,
		affinityKey,
		deployment.Spec.Template.Spec.Affinity.PodAntiAffinity.PreferredDuringSchedulingIgnoredDuringExecution[0].PodAffinityTerm.TopologyKey,
		"Got unexpected affinity topology key",
	)
}
