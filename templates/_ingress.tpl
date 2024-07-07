{{/*
USAGE:
{{ include "mc-chart.ingress" (dict "COMPONENT_NAME" $COMPONENT_NAME "context" .) }}
*/}}

{{- define "mc-chart.ingress" -}}
{{- $context := .context }}
{{- $COMPONENT_NAME := .COMPONENT_NAME -}}
{{- if $context.Values.ingress.enabled }}
apiVersion: {{ include "common.capabilities.ingress.apiVersion" $context }}
kind: Ingress
metadata:
  name: {{ template "common.names.fullname" $context }}
  namespace: {{ include "common.names.namespace" $context | quote }}
  labels: {{- include "common.labels.standard" ( dict "customLabels" $context.Values.commonLabels "context" $context ) | nindent 4 }}
    app.kubernetes.io/component: {{ $COMPONENT_NAME }}
    {{- include "mc.labels.standard" ( dict "context" $context ) | nindent 4 }}
  {{- if or $context.Values.ingress.annotations $context.Values.commonAnnotations }}
  {{- $annotations := include "common.tplvalues.merge" (dict "values" (list $context.Values.ingress.annotations $context.Values.commonAnnotations) "context" $context) }}
  annotations: {{- include "common.tplvalues.render" ( dict "value" $annotations "context" $context ) | nindent 4 }}
  {{- end }}
spec:
  {{- if and $context.Values.ingress.ingressClassName (eq "true" (include "common.ingress.supportsIngressClassname" $context)) }}
  ingressClassName: {{ $context.Values.ingress.ingressClassName | quote }}
  {{- end }}
  rules:
    {{- if $context.Values.ingress.hostname }}
    - host: {{ $context.Values.ingress.hostname }}
      http:
        paths:
          {{- if $context.Values.ingress.extraPaths }}
          {{- toYaml $context.Values.ingress.extraPaths | nindent 10 }}
          {{- end }}
          - path: {{ $context.Values.ingress.path }}
            {{- if eq "true" (include "common.ingress.supportsPathType" .) }}
            pathType: {{ $context.Values.ingress.pathType }}
            {{- end }}
            backend: {{- include "common.ingress.backend" (dict "serviceName" (include "common.names.fullname" $context) "servicePort" "http" "context" $context)  | nindent 14 }}
    {{- end }}
    {{- range $context.Values.ingress.extraHosts }}
    - host: {{ .name | quote }}
      http:
        paths:
          - path: {{ default "/" .path }}
            {{- if eq "true" (include "common.ingress.supportsPathType" $context) }}
            pathType: {{ default "ImplementationSpecific" .pathType }}
            {{- end }}
            backend: {{- include "common.ingress.backend" (dict "serviceName" (include "common.names.fullname" $context) "servicePort" "http" "context" $context) | nindent 14 }}
    {{- end }}
    {{- if $context.Values.ingress.extraRules }}
    {{- include "common.tplvalues.render" (dict "value" $context.Values.ingress.extraRules "context" $context) | nindent 4 }}
    {{- end }}
  {{- if or (and $context.Values.ingress.tls (or (include "common.ingress.certManagerRequest" ( dict "annotations" $context.Values.ingress.annotations )) $context.Values.ingress.selfSigned)) $context.Values.ingress.extraTls }}
  tls:
    {{- if and $context.Values.ingress.tls (or (include "common.ingress.certManagerRequest" ( dict "annotations" $context.Values.ingress.annotations )) $context.Values.ingress.selfSigned) }}
    - hosts:
        - {{ $context.Values.ingress.hostname | quote }}
      secretName: {{ printf "%s-tls" $context.Values.ingress.hostname }}
    {{- end }}
    {{- if $context.Values.ingress.extraTls }}
    {{- include "common.tplvalues.render" (dict "value" $context.Values.ingress.extraTls "context" $context) | nindent 4 }}
    {{- end }}
  {{- end }}
{{- end }}
{{- end }}