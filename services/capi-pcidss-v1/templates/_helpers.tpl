{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "capi-pcidss-v1.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "capi-pcidss-v1.fullname" -}}
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
{{- define "capi-pcidss-v1.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "capi-pcidss-v1.labels" -}}
helm.sh/chart: {{ include "capi-pcidss-v1.chart" . }}
{{ include "capi-pcidss-v1.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "capi-pcidss-v1.selectorLabels" -}}
app.kubernetes.io/name: {{ include "capi-pcidss-v1.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the configs hash
*/}}
{{- define "capi-pcidss-v1.propertiesHash" -}}
{{- $configmap_path := print $.Template.BasePath "/configmap.yaml" -}}
{{- $oopsbodies_path := print $.Template.BasePath "/oops-bodies.yaml" -}}
{{- $config := cat (include $configmap_path .) (include $oopsbodies_path .) | sha256sum -}}
{{- $secret := include (print $.Template.BasePath "/secret.yaml") . | sha256sum -}}
{{- print $secret $config | sha256sum -}}
{{- end -}}

{{/*
Create the name of the service account
*/}}
{{- define "capi-pcidss-v1.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "capi-pcidss-v1.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}
