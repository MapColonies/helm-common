{{/*
USAGE:
{{ include "mc-chart.serviceAccount" (dict "COMPONENT_NAME" $COMPONENT_NAME "context" .) }}
*/}}


{{- define "mc-chart.serviceAccount" -}}
{{- $context := .context -}}
{{- $COMPONENT_NAME := .COMPONENT_NAME -}}
{{- if $context.Values.serviceAccount.create }}
apiVersion: v1
kind: ServiceAccount
metadata:
  name: {{ include "tplHelpers.serviceAccountName" $context }}
  namespace: {{ include "common.names.namespace" $context | quote }}
  labels: {{- include "common.labels.standard" ( dict "customLabels" $context.Values.commonLabels "context" $context ) | nindent 4 }}
    app.kubernetes.io/component: {{ $COMPONENT_NAME }}
    {{- include "mc.labels.standard" ( dict "context" $context ) | nindent 4 }}
  {{- if or $context.Values.serviceAccount.annotations $context.Values.commonAnnotations }}
  {{- $annotations := include "common.tplvalues.merge" (dict "values" (list $context.Values.serviceAccount.annotations $context.Values.commonAnnotations) "context" $context) }}
  annotations: {{- include "common.tplvalues.render" ( dict "value" $annotations "context" $context ) | nindent 4 }}
  {{- end }}
{{- end }}
{{- end }}