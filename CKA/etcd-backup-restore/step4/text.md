### Restore the static pod manifests and the etcd datastore using the backup snapshot

Next, restore the static pod manifests for the **API Server** and **Controller Manager**, then restore **etcd** from the snapshot to revert the cluster to its state prior to the disaster.

Note that restoring etcd only brings back the cluster state, not the deleted manifest files in `/etc/kubernetes/manifests/`.

Tasks:

- Restore the static pods for the API Server and Controller Manager.

- The backup is located at: `/backup/etcd-snapshot.db`

- The restored data directory will be: `/mnt/etcd-data`

Note: It is expected that **kubectl** may be temporarily unavailable until the **kubelet** recreates the static pods. The **API server** may take some time to start, so you can proceed to the next step without waiting.

<details>
<summary>Show commands / answers</summary>
<p>

```bash
# Recreate the static pods (use control-plane; it's not actually the hostname controlplane)
sudo kubeadm init phase control-plane apiserver
sudo kubeadm init phase control-plane controller-manager

# Next, We create the /mnt/ directory
mkdir -p /mnt/

# We restore the cluster
ETCDCTL_API=3 etcdutl snapshot restore /backup/etcd-snapshot.db --data-dir /mnt/etcd-data

# If the previous command fails, try the following one instead (note: this version is deprecated)
ETCDCTL_API=3 etcdctl snapshot restore /backup/etcd-snapshot.db --data-dir /mnt/etcd-data

# Verify the restored directory
ls /mnt/etcd-data
```

</p>
</details>
