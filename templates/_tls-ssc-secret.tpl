{{/*
USAGE:
{{ include "mc-chart.tlsSscSecret" (dict "COMPONENT_NAME" $COMPONENT_NAME "context" .) }}
*/}}

{{- define "mc-chart.tlsSscSecret" -}}
{{- $context := .context }}
{{- $COMPONENT_NAME := .COMPONENT_NAME -}}
{{- if and $context.Values.ingress.enabled $context.Values.ingress.tls $context.Values.ingress.selfSigned }}
{{- $secretName := include "common.secrets.tlsSecretName" (dict "context" $context) }}
{{- $caName := printf "%s-ca" $COMPONENT_NAME }}
{{- $ca := genCA $caName 365 }}
{{- $cert := genSignedCert $context.Values.ingress.hostname nil (list $context.Values.ingress.hostname) 365 $ca }}
apiVersion: v1
kind: Secret
metadata:
  name: {{ $secretName }}
  namespace: {{ include "common.names.namespace" $context | quote }}
  labels: {{- include "common.labels.standard" ( dict "customLabels" $context.Values.commonLabels "context" $context ) | nindent 4 }}
    app.kubernetes.io/component: {{ $COMPONENT_NAME }}
    {{- include "mc.labels.standard" ( dict "context" $context ) | nindent 4 }}
  {{- if $context.Values.commonAnnotations }}
  annotations: {{- include "common.tplvalues.render" ( dict "value" $context.Values.commonAnnotations "context" $context ) | nindent 4 }}
  {{- end }}
type: kubernetes.io/tls
data:
  tls.crt: {{ include "common.secrets.lookup" (dict "secret" $secretName "key" "tls.crt" "defaultValue" $cert.Cert "context" $context) }}
  tls.key: {{ include "common.secrets.lookup" (dict "secret" $secretName "key" "tls.key" "defaultValue" $cert.Key "context" $context) }}
  ca.crt: {{ include "common.secrets.lookup" (dict "secret" $secretName "key" "ca.crt" "defaultValue" $ca.Cert "context" $context) }}
{{- end }}
{{- end }}