{{/*
USAGE:
{{ include "mc-chart.configmap" (dict "COMPONENT_NAME" $COMPONENT_NAME "DATA" $DATA "WITH_TELEMETRY_TRACING" false "WITH_TELEMETRY_METRICS" false "context" .) }}
*/}}

{{- define "mc-chart.configmap" -}}
{{- $context := .context -}}
{{- $COMPONENT_NAME := .COMPONENT_NAME -}}
{{- $DATA := .DATA -}}
{{- $WITH_TELEMETRY_TRACING := .WITH_TELEMETRY_TRACING -}}
{{- $WITH_TELEMETRY_METRICS := .WITH_TELEMETRY_METRICS -}}
{{- $TRACING_OBJECT := include "common.tplvalues.getGlobalObject" (dict "objName" "tracing" "context" $context) | fromYaml -}}
{{- $METRICS_OBJECT := include "common.tplvalues.getGlobalObject" (dict "objName" "metrics" "context" $context) | fromYaml -}}
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
  LOG_LEVEL: {{ $context.Values.env.logLevel | quote }}
  LOG_PRETTY_PRINT_ENABLED: {{ $context.Values.env.logPrettyPrintEnabled | quote }}
  {{- if and $WITH_TELEMETRY_TRACING ($TRACING_OBJECT).enabled }}
  TELEMETRY_TRACING_ENABLED: {{ ($TRACING_OBJECT).enabled | quote }}
  TELEMETRY_TRACING_URL: {{ default $context.Values.global.tracing.url ($TRACING_OBJECT).url}}
  {{- end }}
  {{- if and $WITH_TELEMETRY_METRICS ($METRICS_OBJECT).enabled }}
  TELEMETRY_METRICS_ENABLED: {{ ($METRICS_OBJECT).enabled | quote }}
  TELEMETRY_METRICS_URL: {{ default $context.Values.global.metrics.url ($METRICS_OBJECT).url }}
  TELEMETRY_METRICS_BUCKETS: {{ $context.Values.env.metrics.buckets | toJson | quote }}
  {{- end }}
{{- end }}