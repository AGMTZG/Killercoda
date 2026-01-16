### Install the Helm chart

The final step is to deploy your MongoDB chart to the Kubernetes cluster. This step ensures that the StatefulSet and its dependent Headless Service are created according to the parameters you defined.

Task:

- Install your helm chart by the name `my-database-release` (Make sure you are in the root directory of your Helm chart `database-app/`)

<details>
<summary>Show commands / answers</summary>
<p>

```bash
# Install chart
helm install my-database-release ./

# To check that the resources are running correctly
kubectl get statefulsets
kubectl get pods
kubectl get svc
```

</p>
</details>
