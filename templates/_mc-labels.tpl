{{/*
MapColonies standard labels
{{ include "mc.labels.standard" (dict "context" $) -}}
*/}}
{{- define "mc.labels.standard" -}}
mapcolonies.io/environment: {{ template "tplHelpers.environment" .context }}
{{- if .context.Values.global.owner }}
mapcolonies.io/owner: {{ .context.Values.global.owner | quote }}
{{- end }}
mapcolonies.io/release-version: {{ include "common.tplvalues.getGlobalValue" (dict "propName" "releaseVersion" "context" .context) | default .context.Chart.AppVersion | quote }}
{{- end -}}

{{/*
Labels used on immutable fields such as deploy.spec.selector.matchLabels or svc.spec.selector
{{ include "mc.labels.matchLabels" (dict "context" $) -}}
*/}}
{{- define "mc.labels.matchLabels" -}}
{{ pick (include "mc.labels.standard" (dict "context" .context) | fromYaml) "mapcolonies.io/environment" | toYaml }}
{{- end -}}