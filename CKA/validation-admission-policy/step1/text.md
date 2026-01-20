### Enable ValidatingAdmissionPolicy Feature Gate in Your Cluster

Starting with **Kubernetes 1.30**, the **ValidatingAdmissionPolicy** feature has reached **General Availability (GA)** and is **enabled by default** in the API server. You no longer need to manually set a feature gate for it, and doing so in modern Kubernetes versions can cause the API server to reject the flag and fail to start.

Before creating and enforcing a **ValidatingAdmissionPolicy**, verify that your cluster version supports it and ensure the API server is running normally.

Tasks:

- **Check Your Kubernetes Version**
  - Make sure your cluster is running Kubernetes 1.30 or newer. This can be done with:

```bash
kubectl version --short
```

- **For Kubernetes 1.30+, ValidatingAdmissionPolicy is GA and enabled by default. Do not add a feature gate flag to kube-apiserver.yaml, as it may cause the API server to fail to start. Only clusters running older Kubernetes versions may require explicitly enabling the feature gate**
  - If using an older version, try the following flag and add it to `/etc/kubernetes/manifests/apiserver.yaml` in the commands section.

```bash
--feature-gates=ValidatingAdmissionPolicy=true
```

- **Verify ValidatingAdmissionPolicy API Availability**
  - You can use the following command to check if the ValidatingAdmissionPolicy is running:

```bash
kubectl api-resources | grep ValidatingAdmissionPolicy
```

If you see ValidatingAdmissionPolicy and ValidatingAdmissionPolicyBinding listed, your API server supports them and is ready.
