### Update kubeadm to the target version

Kubeadm orchestrates upgrades in Kubernetes. Upgrading kubeadm first is critical because:

- It ensures compatibility with the desired cluster version.
- Provides the tools necessary to safely upgrade controlplane components.
- Prevents version mismatches during the upgrade.

In this step: before upgrading kubeadm, you must:

- Ensure the kubeadm package is not on hold.
- Update the package list on the machine.
- Check the available versions of kubeadm.
- Ensure the kubeadm package is at the most recent version (In order to get to the next step you should install the most recent kubeadm version).
- Mark the kubeadm package as held once the update is complete.

Note: You can use apt-cache madison to see the packages versions.

<details>
<summary>Show commands / answers</summary>
<p>

```bash
# Unhold kubeadm package
sudo apt-mark unhold kubeadm

# Update package list and check available kubeadm versions
sudo apt update
sudo apt-cache madison kubeadm

kubeadm | < most recent version > | https://pkgs.k8s.io/core:/stable:/v1.34/deb  Packages
kubeadm | 1.34.0-1.1 | https://pkgs.k8s.io/core:/stable:/v1.34/deb  Packages

# Install the target kubeadm version
sudo apt install kubeadm=< most recent version >
sudo apt-mark hold kubeadm
```

</p>
</details>
