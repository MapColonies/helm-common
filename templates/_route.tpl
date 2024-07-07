{{/*
USAGE:
{{ include "mc-chart.route" (dict "COMPONENT_NAME" $COMPONENT_NAME "context" .) }}
*/}}

{{- define "mc-chart.route" -}}
{{- $context := .context }}
{{- $COMPONENT_NAME := .COMPONENT_NAME -}}
{{- if $context.Values.route.enabled }}
apiVersion: {{ include "common.capabilities.route.apiVersion" $context }}
kind: Route
metadata:
  name: {{ template "common.names.fullname" $context }}
  namespace: {{ include "common.names.namespace" $context | quote }}
  labels: {{- include "common.labels.standard" ( dict "customLabels" $context.Values.commonLabels "context" $context ) | nindent 4 }}
    app.kubernetes.io/component: {{ $COMPONENT_NAME }}
    {{- include "mc.labels.standard" ( dict "context" $context ) | nindent 4 }}
  {{- if or $context.Values.route.annotations $context.Values.commonAnnotations }}
  {{- $annotations := include "common.tplvalues.merge" (dict "values" (list $context.Values.route.annotations $context.Values.commonAnnotations) "context" $context) }}
  annotations: {{- include "common.tplvalues.render" ( dict "value" $annotations "context" $context ) | nindent 4 }}
  {{- end }}
spec:
  host: {{ $context.Values.route.hostname }}
  path: {{ $context.Values.route.path }}
  to:
    kind: Service
    name: {{ include "common.names.fullname" $context }}
  port:
    targetPort: {{ $context.Values.route.targetPort }}
  {{- if $context.Values.route.tls.enabled }}
  tls:
    termination: {{ $context.Values.route.tls.termination }}
    insecureEdgeTerminationPolicy: {{ $context.Values.route.tls.insecureEdgeTerminationPolicy }}
    key: {{ $context.Values.route.tls.key | quote }}
    certificate: {{ $context.Values.route.tls.certificate | quote }}
    caCertificate: {{ $context.Values.route.tls.caCertificate | quote }}
  {{- end }}
  {{- if $context.Values.route.extraRules }}
  {{- include "common.tplvalues.render" (dict "value" $context.Values.route.extraRules "context" $context) | nindent 2 }}
  {{- end }}
{{- end }}
{{- end }}