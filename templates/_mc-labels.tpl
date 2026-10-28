{{/*
MapColonies standard labels
{{ include "mc.labels.standard" (dict "context" $) -}}
Label sources (the first non-empty value wins; a label without a value is omitted):
  mapcolonies.io/environment: global.environment                (deployment)
  mapcolonies.io/owner:       mclabels.owner  -> global.owner   (chart override -> deployment)
  mapcolonies.io/part-of:     mclabels.partOf -> global.partOf  (chart override -> deployment)
  mapcolonies.io/component:   mclabels.component                (chart)
*/}}
{{- define "mc.labels.standard" -}}
{{- $values := .context.Values -}}
{{- $mclabels := $values.mclabels | default dict -}}
mapcolonies.io/environment: {{ template "tplHelpers.environment" .context }}
{{- with ($mclabels.owner | default $values.global.owner) }}
mapcolonies.io/owner: {{ . | quote }}
{{- end }}
{{- with ($mclabels.partOf | default $values.global.partOf) }}
mapcolonies.io/part-of: {{ . | quote }}
{{- end }}
{{- with $mclabels.component }}
mapcolonies.io/component: {{ . | quote }}
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

{{/*
MapColonies labels for Pod templates (spec.template.metadata.labels). Never use in selectors.
release-version is omitted so that an umbrella releaseVersion bump does not restart Pods whose spec did not change.
{{ include "mc.labels.pod" (dict "context" $) -}}
*/}}
{{- define "mc.labels.pod" -}}
{{ omit (include "mc.labels.standard" (dict "context" .context) | fromYaml) "mapcolonies.io/release-version" | toYaml }}
{{- end -}}
