{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "capi-v2.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "capi-v2.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "capi-v2.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "capi-v2.labels" -}}
helm.sh/chart: {{ include "capi-v2.chart" . }}
{{ include "capi-v2.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "capi-v2.selectorLabels" -}}
app.kubernetes.io/name: {{ include "capi-v2.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the configs hash
*/}}
{{- define "capi-v2.propertiesHash" -}}
{{- $configmap_path := print $.Template.BasePath "/configmap.yaml" -}}
{{- $oopsbodies_path := print $.Template.BasePath "/oops-bodies.yaml" -}}
{{- $config := cat (include $configmap_path .) (include $oopsbodies_path .) | sha256sum -}}
{{- print $config -}}
{{- end -}}

{{/*
Create the secrets hash
*/}}
{{- define "capi-v2.secretsHash" -}}
{{- $config := include (print $.Template.BasePath "/secret.yaml") . | sha256sum -}}
{{- print $config -}}
{{- end -}}

