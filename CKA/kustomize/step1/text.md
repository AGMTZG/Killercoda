### Configure the Dev Environment with Kustomize

In this step, you will customize the development environment for the database using Kustomize.  

You will:

- Create a `kustomization.yaml` file inside the `base` folder, which is located in the `app` folder in your **home directory** and add the `headless-service.yaml` and `statefulset.yaml` files under resources in the `kustomization.yaml`.

- In your **home directory**, inside the `app` folder, create an `overlays` folder with a `subfolder dev`. Place the `kustomization.yaml` file inside `overlays/dev`.

### StatefulSet - Name: mysql

- Update the MySQL image `mysql` to `mysql:dev`.

- Add nameSuffix `-dev`, the label `env: dev` and the annotation  `resource: development` to all resources.

- Create a `patch.json` that updates the StatefulSet to run 2 replicas.

- In the same `patch.json`, add an initContainer named `init-permissions` using the `busybox` image, with a volumeMount called `mysql-volume`, to set the correct `mysql:mysql` ownership on `/var/lib/mysql` before the main container starts by running the following command:

```bash
chown -R mysql:mysql /var/lib/mysql
```

Note: Do not create ConfigMaps or Secrets in the dev overlay. The base manifests provide the required configuration values, and Kustomize replacements will only be introduced in the prod overlay to demonstrate environment-specific configuration injection.

After completing these tasks, your **dev** overlay will be ready for deployment.

<details>
<summary>Show commands / answers</summary>
<p>

```bash
~/app
└── base
    └── headless-service.yaml
    └── statefulset.yaml
    └── kustomization.yaml

# kustomization.yaml
resources:
- statefulset.yaml
- headless-service.yaml

~/app
└── overlays
    └── dev
        └── kustomization.yaml
        └── patch.json

# kustomization.yaml
resources: 
- ../../base 

nameSuffix: -dev

images: 
  - name: mysql 
    newName: mysql 
    newTag: dev 
 
labels: 
- pairs: 
    env: dev 
  includeSelectors: true 
  includeTemplates: true 

commonAnnotations:
  resource: development
 
patches: 
- target: 
    group: apps 
    version: v1 
    kind: StatefulSet 
    name: mysql 
  path: patch.json

# patch.json
[
  {
    "op": "replace",
    "path": "/spec/replicas",
    "value": 2
  },
  {
    "op": "add",
    "path": "/spec/template/spec/initContainers",
    "value": [
      {
        "name": "init-permissions",
        "image": "busybox",
        "command": ["sh", "-c", "chown -R mysql:mysql /var/lib/mysql"],
        "volumeMounts": [
          {
            "name": "mysql-volume",
            "mountPath": "/var/lib/mysql"
          }
        ]
      }
    ]
  }
]
```

</p>
</details>
