### Configure the Dev Environment with Kustomize

In this step, you will customize the development environment for the database using Kustomize.  

You will:

- Create a `kustomization.yaml` file inside the `base` folder, which is located in the `app` folder in your **home directory** and add the `headless-service.yaml` and `statefulset.yaml` files under resources in the `kustomization.yaml`.

- In your **home directory**, inside the `app` folder, create an `overlays` folder with a `subfolder dev`. Place the `kustomization.yaml` file inside `overlays/dev`.

### StatefulSet - Name: mysql

- Update the MySQL image `mysql` to `mysql:dev`.

- Add the label `env: dev` to all resources.

- Create a `patch.json` file to set the environment variable `DEBUG=true`.

- In the same `patch.json`, add an initContainer using the BusyBox image to set the correct `mysql:mysql` ownership on `/var/lib/mysql` before the main container starts by running the following command:

```bash
chown -R mysql:mysql /var/lib/mysql
```

- Generate a ConfigMap named `db-config` that includes the literals `DB_HOST=localhost` and `DB_PORT=3306`.

- Create a Secret named `db-secret` that includes the literals `USERNAME=admin` and `PASSWORD=asdfqwerty`.

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
 
images: 
  - name: mysql 
    newName: mysql 
    newTag: dev 
 
labels: 
- pairs: 
    env: dev 
  includeSelectors: true 
  includeTemplates: true 
 
configMapGenerator: 
- name: db-config 
  literals: 
    - DB_HOST=localhost 
    - DB_PORT=3306 
 
secretGenerator: 
- name: db-secret 
  literals: 
    - USERNAME=admin 
    - PASSWORD=asdfqwerty 
 
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
    "op": "add",
    "path": "/spec/template/spec/containers/0/env/-",
    "value": {
      "name": "DEBUG",
      "value": "true"
    }
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
            "name": "mysql_volume",
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
