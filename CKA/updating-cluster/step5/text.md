### Upgrade kubectl

Finally, upgrade your local `kubectl` to ensure it matches the cluster version.

In this step, you will:

- Ensure the kubectl package is not on hold.
- Update kubectl to the latest version (it must match the kubelet and kubeadm versions).
- Put the kubectl package on hold.

<details>
<summary>Show commands / answers</summary>
<p>

```bash
# Upgrade kubectl to the same version as cluster
sudo apt-mark unhold kubectl
sudo apt install -y kubectl=< most recent version >
sudo apt-mark hold kubectl
```

</p>
</details>
