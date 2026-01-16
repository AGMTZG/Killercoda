### Modify the Helm Chart Templates

In this step, you will modify the Helm chart templates to deploy a MongoDB database using a StatefulSet and a headless Service. You will reuse the helpers defined in `_helpers.tpl`.

Tasks:

**Step 1: Clean up the default templates**

Inside the templates/ directory:

- Remove all default Helm chart templates, including `NOTES.txt`, except for `_helpers.tpl` and the folder `tests`.
- Move all provided YAML files from the `~/` (home directory) into `templates/`.

This ensures the chart only contains resources relevant to MongoDB.


**Step 2: Update the StatefulSet template**

Modify the StatefulSet template to use values and helpers instead of hardcoded fields.

**Metadata and labels**

Use the helpers defined in `_helpers.tpl`:

- `metadata.name`: Use database-app.name
- `metadata.labels`: Use database-app.labels
- `spec.selector.matchLabels`: Use database-app.selectorLabels
- `template.metadata.labels`: Use database-app.labels

This ensures labels are consistent across all resources.

**Step 3: Update the headless Service template**

Modify the Headless Service template to use the helpers defined in `_helpers.tpl` instead of hardcoded values.

**Metadata and selectors**

Use the helpers to ensure consistency with the StatefulSet:

- `metadata.name`: Use database-app.name.
- `metadata.labels`: Use database-app.labels.
- `spec.selector`: Use database-app.selectorLabels.

This ensures the Headless Service correctly selects the Pods created by the StatefulSet and shares the same naming and labeling conventions.

<details>
<summary>Click here to see helpers.tpl</summary>
<p>

```bash
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

<details>
<summary>Show commands / answers</summary>
<p>

```bash
# Navigate to the templates directory
cd database-app/templates

# Remove the default templates
rm deployment.yaml service.yaml hpa.yaml httproute.yaml ingress.yaml serviceaccount.yaml NOTES.txt

# Return to the home directory
cd

# Move the provided templates to the templates/ directory
mv statefulset.yaml headless-service.yaml database-app/templates/

# templates/statefulset.yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: {{ include "database-app.name" . }}
  labels:
    {{- include "database-app.labels" . | nindent 4 }}
spec:
  serviceName: {{ include "database-app.name" . }}
  replicas: 1
  selector:
    matchLabels:
      {{- include "database-app.selectorLabels" . | nindent 6 }}
  template:
    metadata:
      labels:
        {{- include "database-app.labels" . | nindent 8 }}
    spec:
      containers:
        - name: mongo
          image: mongo:6.0
          ports:
            - containerPort: 27017
          env:
            - name: MONGO_INITDB_ROOT_USERNAME
              value: mongoadmin
            - name: MONGO_INITDB_ROOT_PASSWORD
              value: 123456789


# templates/headless-service.yaml

apiVersion: v1
kind: Service
metadata:
  name: {{ include "database-app.name" . }}
  labels:
    {{- include "database-app.labels" . | nindent 4 }}
spec:
  clusterIP: None
  selector:
    {{- include "database-app.selectorLabels" . | nindent 4 }}
  ports:
    - port: 27017
      targetPort: 27017
```

</p>
</details>
