### Configure the Prod Environment with Kustomize

In this step, you will customize the production environment for the database using Kustomize.  

You will:

- In your **home directory**, inside the `app` folder, create an `overlays` folder with a `subfolder prod`. Place the `kustomization.yaml` file inside `overlays/prod`.

### StatefulSet - Name: mysql
 
- Update the MySQL image `mysql` to `mysql:prod`.

- Add nameSuffix `-prod`, the label `env: prod` and the annotation  `resource: production` to all resources.

- Disable the name suffix hash for both the ConfigMap and the Secret.

- Create a ConfigMap named `db-host` that includes the literals `DB_HOST=mysql-prod.company.local` and `DB_PORT=3306`, , and use Kustomize replacements to inject these values into the appropriate environment variables of the MySQL container.

- Create a Secret named `db-secret` that includes the literals `USERNAME=prod_admin` and `PASSWORD=G7hT9pX2!zQ4`, , and use Kustomize replacements to inject these values into the appropriate environment variables of the MySQL container.

After completing these tasks, your **prod** overlay will be ready for deployment.

<details>
<summary>Show commands / answers</summary>
<p>

```bash
~/app
└── overlays
    └── prod
        └── kustomization.yaml

# kustomization.yaml
resources:  
- ../../base  

nameSuffix: -prod
  
images:  
  - name: mysql  
    newName: mysql  
    newTag: prod 
  
labels:  
- pairs:  
    env: prod 
  includeSelectors: true  
  includeTemplates: true

commonAnnotations:
  resource: production
  
configMapGenerator:  
- name: db_host  
  literals:  
    - DB_HOST=mysql-prod.company.local 
    - DB_PORT=3306 
  
secretGenerator:  
- name: db_secret
  literals:  
    - USERNAME=prod_admin 
    - PASSWORD=G7hT9pX2!zQ4 

generatorOptions:
  disableNameSuffixHash: true

replacements:
  - source:
      kind: ConfigMap
      name: db-host
      fieldPath: data.DB_HOST
    targets:
      - select:
          kind: StatefulSet
          name: mysql
        fieldPaths:
          - spec.template.spec.containers.[name=mysql].env.[name=DB_HOST].value

  - source:
      kind: ConfigMap
      name: db-host
      fieldPath: data.DB_PORT
    targets:
      - select:
          kind: StatefulSet
          name: mysql
        fieldPaths:
          - spec.template.spec.containers.[name=mysql].env.[name=DB_PORT].value

  - source:
      kind: Secret
      name: db-secret
      fieldPath: data.USERNAME
    targets:
      - select:
          kind: StatefulSet
          name: mysql
        fieldPaths:
          - spec.template.spec.containers.[name=mysql].env.[name=MYSQL_USER].value

  - source:
      kind: Secret
      name: db-secret
      fieldPath: data.PASSWORD
    targets:
      - select:
          kind: StatefulSet
          name: mysql
        fieldPaths:
          - spec.template.spec.containers.[name=mysql].env.[name=MYSQL_PASSWORD].value
```

</p>
</details>
