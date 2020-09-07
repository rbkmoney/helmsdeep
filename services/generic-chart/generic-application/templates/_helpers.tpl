{{/* vim: set filetype=mustache: */}}

{{/*
Create a default initialDelaySeconds for liveness probe
so it will not fail before readinessProbe finished
*/}}
{{- define "livenessProbeInitialDelaySeconds" -}}
{{- add .Values.app.probes.initialDelaySeconds .Values.app.probes.periodSeconds -}}
{{- end -}}
