### Upgrade kubelet on the controlplane node

The kubelet must match the controlplane version. Steps include:

- Draining the node to safely evict pods.
- Ensure the kubelet package is not on hold.
- Installing the kubelet package to the latest version (it must match the one installed with kubeadm).
- Restarting the kubelet to apply the upgrade.
- Put the kubelet package on hold.
- Uncordoning the node to allow new pods to schedule.


<details>
<summary>Show commands / answers</summary>
<p>

```bash
# Drain the controlplane node
kubectl drain ubuntu --ignore-daemonsets

# Upgrade kubelet
sudo apt-mark unhold kubelet
sudo apt install -y kubelet=< most recent version >
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl restart kubelet

# Lock the kubeadm package
sudo apt-mark hold kubelet

# Uncordon the node after upgrade
kubectl uncordon ubuntu

# We check if the controlplane has been updated:
kubectl get nodes
```

</p>
</details>
