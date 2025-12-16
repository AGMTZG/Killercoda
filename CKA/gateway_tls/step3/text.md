### Create HTTPSRoutes for Each Hostname

In this step, you will define HTTPRoute resources to route traffic from your Gateway `my-tls-gateway` to the backend services. 
Each hostname requires its own HTTPRoute, and each route must include rules for all paths associated with that host. The Gateway will handle TLS termination using the secret `my-secret` for HTTPS listeners.

You’ll create one route per hostname: `app.home.local` and `app.contact.local`.

The HTTPRoute named `http-home` routes traffic as follows:

- `/` → `home-svc`
- `/sales` → `sales-svc `

A URLRewrite filter is required for the `/sales` endpoint.

The HTTPRoute named `http-contact` routes traffic as follows:

- `/contact` → `contact-svc`
- `/about` → `about-us-svc`

A URLRewrite filter is required for `/about` endpoint.

Note: All deployments use the NGINX image and expose port 80.


|Host               | Path      | Backend Service |
|-------------------|-----------|-----------------|
|app.home.local     |  /	    | home-svc        |
|app.home.local	    |  /sales   | sales-svc       |
|app.contact.local  |  /contact | contact-svc     |
|app.contact.local  |  /about   | about-us-svc    |


<details>
<summary>Show commands / answers</summary>
<p>

```bash
# First HTTPRoute for app.home.local

apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: http-home
spec:
  parentRefs:
  - name: my-tls-gateway
  hostnames:
  - app.home.local
  rules:
  - matches:
    - path:
        type: PathPrefix
        value: /
    backendRefs:
    - name: home-svc
      port: 80
  - matches:
    - path:
        type: PathPrefix
        value: /sales
    backendRefs:
    - name: sales-svc
      port: 80
    filters:
    - type: URLRewrite
      urlRewrite:
        path:
          type: ReplacePrefixMatch
          replacePrefixMatch: /

# Second HTTP Route for orders.company.local

apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: http-contact
spec:
  parentRefs:
  - name: my-tls-gateway
  hostnames: 
  - app.contact.local
  rules:
  - matches:
    - path:
        type: PathPrefix
        value: /contact
    backendRefs:
    - name: contact-svc
      port: 80
    filters:
    - type: URLRewrite
      urlRewrite:
        path:
          type: ReplacePrefixMatch
          replacePrefixMatch: /
  - matches:
    - path:
        type: PathPrefix
        value: /about
    backendRefs:
    - name: about-us-svc
      port: 80
    filters:
    - type: URLRewrite
      urlRewrite:
        path:
          type: ReplacePrefixMatch
          replacePrefixMatch: /
```

</p>
</details>
