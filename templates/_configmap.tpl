{{/*
USAGE:
{{ include "mc-chart.configmap" (dict "MAIN_OBJECT_BLOCK" $MAIN_OBJECT_BLOCK "COMPONENT_NAME" $COMPONENT_NAME "DATA" $DATA "context" .) }}
*/}}

{{- define "mc-chart.configmap" -}}
{{- $context := .context }}
{{- $COMPONENT_NAME := .COMPONENT_NAME -}}
{{- $DATA := .DATA -}}
{{- $MAIN_OBJECT_BLOCK := get $context.Values .MAIN_OBJECT_BLOCK -}}
 
apiVersion: {{ include "common.capabilities.configmap.apiVersion" $context }}
kind: ConfigMap
metadata:
  name: {{ template "common.names.fullname" $context }}
  namespace: {{ include "common.names.namespace" $context | quote }}
  labels: {{- include "common.labels.standard" ( dict "customLabels" $context.Values.commonLabels "context" $context ) | nindent 4 }}
    app.kubernetes.io/component: {{ $COMPONENT_NAME }}
    {{- include "mc.labels.standard" ( dict "context" $context ) | nindent 4 }}
  {{- if $context.Values.commonAnnotations }}
  {{- $annotations := include "common.tplvalues.merge" (dict "values" (list $context.Values.commonAnnotations) "context" $context) }}
  annotations: {{- include "common.tplvalues.render" ( dict "value" $annotations "context" $context ) | nindent 4 }}
  {{- end }}
data:
  {{ include "common.tplvalues.render" ( dict "value" $DATA "context" $context )}}
{{- end }}