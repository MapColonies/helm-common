{{/*
USAGE:
{{ include "mc-chart.tlsCrtSecret" (dict "COMPONENT_NAME" $COMPONENT_NAME "hostname" $hostname "certificate" $certificate "key" $key "context" .) }}
*/}}

{{- define "mc-chart.tlsCrtSecret" -}}
{{- $context := .context -}}
{{- $hostname := .hostname -}}
{{- $certificate := .certificate -}}
{{- $key := .key -}}
{{- $COMPONENT_NAME := .COMPONENT_NAME -}}
apiVersion: v1
kind: Secret
metadata:
  name: {{ include "common.secrets.tlsSecretName" (dict "context" $context "hostname" $hostname) }}
  namespace: {{ include "common.names.namespace" $context | quote }}
  labels: {{- include "common.labels.standard" ( dict "customLabels" $context.Values.commonLabels "context" $context ) | nindent 4 }}
    app.kubernetes.io/component: {{ $COMPONENT_NAME }}
    {{- include "mc.labels.standard" ( dict "context" $context ) | nindent 4 }}
  {{- if $context.Values.commonAnnotations }}
  annotations: {{- include "common.tplvalues.render" ( dict "value" $context.Values.commonAnnotations "context" $context ) | nindent 4 }}
  {{- end }}
type: kubernetes.io/tls
data:
  tls.crt: {{ $certificate | b64enc }}
  tls.key: {{ $key | b64enc }}
{{- end }}