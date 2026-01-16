### Update Helm Helper Templates

In this step, you will create Helm helper templates. Helpers are small reusable functions that help you avoid repeating the same values (like names and labels) across your Kubernetes manifests.

**What you will do**

You will work with the `_helpers.tpl` file inside the templates/ directory and define a few helpers that will be reused by other templates in the chart.

Tasks: 

**Step 1: Reset the helpers file**

- Go to the `templates/` directory.
- Delete the existing `_helpers.tpl` file.
- Create a new empty file called `_helpers.tpl`.


**Step 2: Define the chart name helper**

In the new `_helpers.tpl`, create a helper called `database-app.name`. This helper should have the chart name:

**Step 3: Create a helper for resource names**

Then, create a helper called `database-app.fullname`. This helper should generate a unique name for Kubernetes resources by combining:

- the Helm release name
- a hyphen (-)
- the chart name

Expected format:

```bash
<release-name>-<chart-name>
```
This pattern ensures that resources remain unique when the same chart is installed multiple times with different release names.

**Step 4: Create a helper for common labels**

In the same file, create another helper called `database-app.labels`. This helper will return a common set of labels that should be added to all Kubernetes resources in the chart. Use the following labels:

- **app.kubernetes.io/name:** the application (chart) name
- **app.kubernetes.io/instance:** the Helm release name

Expected format:

```bash
app.kubernetes.io/name: <application-name>
app.kubernetes.io/instance: <release-name>
```
These labels are part of the recommended Kubernetes labeling conventions.

**Step 5: Create a helper for selector labels**

Next, create a helper called `database-app.selectorLabels`. This helper will be used in selectors (for example, in Deployments and Services) and should contain only the minimum required labels.
Use this label:

- **app.kubernetes.io/name**: the application (chart) name

```bash
app.kubernetes.io/name: <application-name>
```

**Key concepts to remember**
- Helpers are defined using `define` inside `_helpers.tpl`
- Helpers are reused in other templates using `include`

<details>
<summary>Show commands / answers</summary>
<p>

```bash
# Navigate to the templates directory
cd database-app/templates

# Remove the existing _helpers.tpl if it exists and create a new one
rm -f _helpers.tpl
touch _helpers.tpl

vim _helpers.tpl

# _helpers.tpl

{{- define "database-app.name" -}}
{{ .Chart.Name }}
{{- end }}

{{- define "database-app.fullname" -}}
{{ .Release.Name }}-{{ .Chart.Name }}
{{- end }}

{{- define "database-app.labels" -}}
app.kubernetes.io/name: {{ include "database-app.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "database-app.selectorLabels" -}}
app.kubernetes.io/name: {{ include "database-app.name" . }}
{{- end }}
```

</p>
</details>
