{{/* vim: set filetype=mustache: */}}
{{/*
Create linea besu name and version as used by the chart label.
*/}}
{{- define "linea.besu.fullname" -}}
{{- printf "%s-%s" (include "linea.fullname" .) .Values.besu.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create the name of the besu service account to use
*/}}
{{- define "linea.besu.serviceAccountName" -}}
{{- if .Values.besu.serviceAccount.create -}}
    {{ default (include "linea.besu.fullname" .) .Values.besu.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.besu.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Create the address of the besu to use
*/}}
{{- define "linea.besu.addr" -}}
{{- printf "%s-0.%s-headless.%s.svc.cluster.local" (include "linea.besu.fullname" .) (include "linea.besu.fullname" .) (.Release.Namespace) -}}
{{- end -}}

{{/*
Create linea ethstats name and version as used by the chart label.
*/}}
{{- define "linea.ethstats.fullname" -}}
{{- printf "%s-%s" (include "linea.fullname" .) .Values.ethstats.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create the name of the ethstats service account to use
*/}}
{{- define "linea.ethstats.serviceAccountName" -}}
{{- if .Values.ethstats.serviceAccount.create -}}
    {{ default (include "linea.ethstats.fullname" .) .Values.ethstats.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.ethstats.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Create the address of the sequencer to use
*/}}
{{- define "linea.ethstats.addr" -}}
{{- printf "%s.%s:%d" (include "linea.ethstats.fullname" .) (.Release.Namespace) (int .Values.ethstats.service.port) -}}
{{- end -}}


{{/*
Create linea maru name and version as used by the chart label.
*/}}
{{- define "linea.maru.fullname" -}}
{{- printf "%s-%s" (include "linea.fullname" .) .Values.maru.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create the name of the ethstats service account to use
*/}}
{{- define "linea.maru.serviceAccountName" -}}
{{- if .Values.maru.serviceAccount.create -}}
    {{ default (include "linea.maru.fullname" .) .Values.maru.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.maru.serviceAccount.name }}
{{- end -}}
{{- end -}}l

{{/*
Create linea sequencer name and version as used by the chart label.
*/}}
{{- define "linea.sequencer.fullname" -}}
{{- printf "%s-%s" (include "linea.fullname" .) .Values.sequencer.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create the name of the ethstats service account to use
*/}}
{{- define "linea.sequencer.serviceAccountName" -}}
{{- if .Values.sequencer.serviceAccount.create -}}
    {{ default (include "linea.sequencer.fullname" .) .Values.sequencer.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.sequencer.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Create the address of the sequencer to use
*/}}
{{- define "linea.sequencer.addr" -}}
{{- printf "%s-0.%s-headless.%s.svc.cluster.local" (include "linea.sequencer.fullname" .) (include "linea.sequencer.fullname" .) (.Release.Namespace ) -}}
{{- end -}}

{{/*
Create linea sequencer name and version as used by the chart label.
*/}}
{{- define "linea.sender.fullname" -}}
{{- printf "%s-%s" (include "linea.fullname" .) .Values.sender.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create the name of the sender service account to use
*/}}
{{- define "linea.sender.serviceAccountName" -}}
{{- if .Values.sequencer.serviceAccount.create -}}
    {{ default (include "linea.sender.fullname" .) .Values.sequencer.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.sender.serviceAccount.name }}
{{- end -}}
{{- end -}}
