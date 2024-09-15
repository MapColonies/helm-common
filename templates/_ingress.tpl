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
  {{- $annotations := include "common.tplvalues.merge" (dict "values" (list $context.Values.ingress.annotations $context.Values.commonAnnotations) "context" $context) }}
  annotations: {{- include "mc-chart.ingress.nginx.annotations" ( dict "context" $context ) | indent 4 -}}
  {{- if ne $annotations "{}" -}}
  {{- include "common.tplvalues.render" ( dict "value" $annotations "context" $context ) | nindent 4 }}
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
            {{- if eq "true" (include "common.ingress.supportsPathType" $context) }}
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
      secretName: {{ include "common.secrets.tlsSecretName" (dict "context" $context) }}
    {{- end }}
    {{- if $context.Values.ingress.extraTls }}
    {{- include "common.tplvalues.render" (dict "value" $context.Values.ingress.extraTls "context" $context) | nindent 4 }}
    {{- end }}
  {{- end }}
{{- end }}
{{- end }}

{{- define "mc-chart.ingress.nginx.annotations" -}}
{{- $context := .context }}
{{- $flavor := include "common.images.deploymentFlavor" ( dict "imageRoot" nil "global" $context.Values.global ) -}}
{{- if ne $flavor "openshift" -}}
kubernetes.io/ingress.class: "nginx"
{{- end -}}
{{- if eq $context.Values.ingress.type "nginx-org" }}
nginx.org/mergeable-ingress-type: "minion"
nginx.org/rewrites: 'serviceName={{ template "common.names.fullname" $context }} rewrite=/'
{{- end }}
{{- if eq $context.Values.ingress.type "nginx-kubernetes" }}
nginx.ingress.kubernetes.io/rewrite-target: /$2
{{- end }}  
nginx.org/location-snippets: |
  if ($request_method = OPTIONS) {
    return 204;
  }
{{- if $context.Values.ingress.cors.enabled }}
  add_header 'Access-Control-Allow-Origin' '{{- $context.Values.ingress.cors.origin -}}';
  add_header 'Access-Control-Max-Age' 3600;
  add_header 'Access-Control-Expose-Headers' 'Content-Length';
  add_header 'Access-Control-Allow-Headers' '*';
{{- end }}
{{- end }}