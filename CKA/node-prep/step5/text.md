### Ensure required ports are open

Kubernetes components need specific ports to communicate properly between nodes:

- 6443 → kube-apiserver (API server for the cluster)

- 2379–2380 → etcd (key-value store used by Kubernetes)

- 10250 → kubelet (manages pods on the node)

<details>
<summary>Show commands / answers</summary>
<p>

```bash
# If UFW is not enabled, enable it:
sudo ufw enable

sudo ufw allow 6443/tcp
sudo ufw allow 2379:2380/tcp
sudo ufw allow 10250/tcp

# Verify the rules
sudo ufw status

```

</p>
</details>
