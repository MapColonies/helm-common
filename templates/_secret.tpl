{{/*
USAGE:
{{ include "mc-chart.secret" (dict "COMPONENT_NAME" $COMPONENT_NAME "SECRET" $SECRET "context" .) }}
*/}}

{{- define "mc-chart.secret" -}}
{{- $context := .context -}}
{{- $SECRET := .SECRET -}}
{{- $COMPONENT_NAME := .COMPONENT_NAME -}}
apiVersion: v1
kind: Secret
metadata:
  name: {{ $SECRET.name }}
  namespace: {{ include "common.names.namespace" $context | quote }}
  labels: {{- include "common.labels.standard" ( dict "customLabels" $context.Values.commonLabels "context" $context ) | nindent 4 }}
    app.kubernetes.io/component: {{ $COMPONENT_NAME }}
    {{- include "mc.labels.standard" ( dict "context" $context ) | nindent 4 }}
  {{- if $context.Values.commonAnnotations }}
  annotations: {{- include "common.tplvalues.render" ( dict "value" $context.Values.commonAnnotations "context" $context ) | nindent 4 }}
  {{- end }}
type: {{ $SECRET.type }}
data:
  {{- range $SECRET.data }}
  {{ .key }}: {{ .value | b64enc }}
  {{- end }}
{{- end }}