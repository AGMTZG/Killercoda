### Create and Verify the StorageClass

Your manager has requested you to configure a custom **StorageClass** that meets specific performance and retention requirements.
The goal is to create a **StorageClass** that ensures persistent volumes are retained after deletion, support volume expansion, and are provisioned only when pods are scheduled.

After creating it, you must also verify which **StorageClass** is currently set as default and store the result in a specific directory for auditing purposes.

Requirements

- Create a **StorageClass** named `csi-retain-sc` with the following specifications:

  - **Provisioner**: `csi-driver.example-vendor.example` (not dynamic — it does not automatically create PersistentVolumes)

  - **Reclaim policy**: `Retain`

  - **Volume expansion**: `True`

  - **Mount option**: `discard`

  - **Volume binding mode**: `WaitForFirstConsumer`

  - **Parameter**: `guaranteedReadWriteLatency: "true"`

  - Set this **StorageClass** as `default`

**Important**: Before setting this **StorageClass** as `default`, you must remove the `default` annotation from the current default **StorageClass**.

Save the configuration and apply it to the cluster.

Finally:

Run the appropriate command to determine which **StorageClass** is marked as default and save the output to `/opt/storage/default-sc.txt`.

**Note**: the directory `/opt/storage` may not exist yet, so make sure to create it before saving the file:

Requirements for the file `/opt/storage/default-sc.txt`:

- The output must display only one **StorageClass** and include exactly two columns: `NAME` (the name of the **StorageClass**) and `DEFAULT` (indicating whether it is set as default).

- You may include headers or not, as long as the default StorageClass can be identified.

Examples:

```bash

# Example 1: using the annotation as a column
NAME               DEFAULT
csi-retain-sc      true

# Example 2: using "default" as a human-readable value
NAME               DEFAULT
csi-retain-sc      default

# Example 3: without headers, just the information
csi-retain-sc      true

```

<details>
<summary>Show commands / answers</summary>
<p>

```bash
# First, Remove the annotation from the default storage class
kubectl get storageclass

NAME                      PROVISIONER                         RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
local-path (default)      rancher.io/local-path               Delete          WaitForFirstConsumer   false                  20d

kubectl edit storageclass local-path

# Remove the annotation
storageclass.kubernetes.io/is-default-class: "true"

# Next, we create the storage class yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: csi-retain-sc
  annotations:
    storageclass.kubernetes.io/is-default-class: "true"
provisioner: csi-driver.example-vendor.example
reclaimPolicy: Retain
allowVolumeExpansion: true
volumeBindingMode: WaitForFirstConsumer
parameters:
  guaranteedReadWriteLatency: "true"
mountOptions:
- discard
volumeBindingMode: WaitForFirstConsumer

# Create the /opt/storage folder
mkdir -p /opt/storage/

# Then create the command
kubectl get storageclass -o jsonpath='{range .items[?(@.metadata.annotations.storageclass\.kubernetes\.io/is-default-class=="true")]}{.metadata.name}{"\t"}{.metadata.annotations.storageclass\.kubernetes\.io/is-default-class}{"\n"}{end}'
```

</p>
</details>
