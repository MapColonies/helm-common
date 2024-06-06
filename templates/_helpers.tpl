{{/*
Copyright Broadcom, Inc. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/*
Return the proper %%MAIN_OBJECT_BLOCK%% image name
*/}}
{{- define "tplHelpers.image" -}}
{{- $MAIN_OBJECT_BLOCK := .MAIN_OBJECT_BLOCK -}}
{{- $context := .context -}}
{{- include "common.images.image" (dict "imageRoot" $MAIN_OBJECT_BLOCK.image "global" $context.Values.global) -}}
{{- end -}}

{{/*
Return the proper image name (for the init container volume-permissions image)
*/}}
{{- define "tplHelpers.volumePermissions.image" -}}
{{- include "common.images.image" ( dict "imageRoot" .Values.volumePermissions.image "global" .Values.global ) -}}
{{- end -}}

{{/*
Return the proper Docker Image Registry Secret Names
*/}}
{{- define "tplHelpers.imagePullSecrets" -}}
{{- $MAIN_OBJECT_BLOCK := .MAIN_OBJECT_BLOCK -}}
{{- $context := .context -}}
{{- include "common.images.renderPullSecrets" (dict "images" (list $MAIN_OBJECT_BLOCK.image $context.Values.volumePermissions.image) "context" $context) -}}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "tplHelpers.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "common.names.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Return true if cert-manager required annotations for TLS signed certificates are set in the Ingress annotations
Ref: https://cert-manager.io/docs/usage/ingress/#supported-annotations
*/}}
{{- define "tplHelpers.ingress.certManagerRequest" -}}
{{ if or (hasKey . "cert-manager.io/cluster-issuer") (hasKey . "cert-manager.io/issuer") }}
    {{- true -}}
{{- end -}}
{{- end -}}

{{/*
Compile all warnings into a single message.
*/}}
{{- define "tplHelpers.validateValues" -}}
{{- $messages := list -}}
{{- $messages := append $messages (include "tplHelpers.validateValues.foo" .) -}}
{{- $messages := append $messages (include "tplHelpers.validateValues.bar" .) -}}
{{- $messages := without $messages "" -}}
{{- $message := join "\n" $messages -}}

{{- if $message -}}
{{-   printf "\nVALUES VALIDATION:\n%s" $message -}}
{{- end -}}
{{- end -}}

{{/*
Returns the environment from global
*/}}
{{- define "tplHelpers.environment" -}}
{{- .Values.global.environment -}}
{{- end -}}

{{/*
Returns probe httpGet 
*/}}
{{- define "tplHelpers.probe.httpGet" -}}
{{- $PROBE_PATH := .PROBE_PATH | default "liveness" -}}
httpGet:
  path: /{{ $PROBE_PATH }}
  port: http
{{- end -}}