{{/* vim: set filetype=mustache: */}}

{{/*
Expand the name of the chart.
*/}}
{{- define "test-transaction.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "test-transaction.fullname" -}}
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
{{- define "test-transaction.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Job labels
*/}}
{{- define "test-transaction.labels" -}}
helm.sh/chart: {{ include "test-transaction.chart" . }}
{{ include "test-transaction.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Job selector labels
*/}}
{{- define "test-transaction.selectorLabels" -}}
app.kubernetes.io/name: {{ include "test-transaction.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Gateway labels
*/}}
{{- define "test-transaction.gwLabels" -}}
helm.sh/chart: {{ include "test-transaction.chart" . }}
{{ include "test-transaction.gwSelectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Gateway selector  labels
*/}}
{{- define "test-transaction.gwSelectorLabels" -}}
app.kubernetes.io/name: {{ include "test-transaction.name" . }}-gateway
app.kubernetes.io/instance: {{ .Release.Name }}-gateway
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "test-transaction.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "test-transaction.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the gateway configs hash
*/}}
{{- define "test-transaction.gwPropertiesHash" -}}
{{- $config := include (print $.Template.BasePath "/configmap.yaml") . | sha256sum -}}
{{ print $config | sha256sum }}
{{- end -}}
