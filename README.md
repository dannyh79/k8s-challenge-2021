## DigitalOcean Kubernetes Challenge 2021 - Deploy a scalable SQL database cluster
### Prereqs
- [Some basic understanding of Kubernetes](https://kubernetes.io/docs/concepts/)
- A DO account
- A domain
- Postgres CLI (psql)
- [kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl), [lens](https://k8slens.dev/), and [helm](https://helm.sh/docs/intro/install/)

### Getting Started
#### 1. Create a Kube Cluster
1. Create a VPC (networking -> VPC -> Create VPC Network)
2. Create a Kube Cluster
  - Node pool name: pool-kube-challenge
  - Node plan: $15 a month; count 3
  - Finalize
    - Name: kube-challenge

#### 2. Connecting to Kube Clusters
1. Download cluster config file
2. Connect to the cluster; two ways
  - Kubectl
      ```sh
      $ mv ~/Downloads/kube-challenge-kubeconfig.yaml ./
      $ export KUBECONFIG=./kube-challenge-kubeconfig.yaml
      $ kubectl config get-contexts
      $ kubectl get nodes
      ```

  - Lens
    1. Add cluster from kubeconfig
    2. Paste content into the textarea
    3. Add cluster
    4. Add to hotbar
    5. Go to the cluster's settings and apply the 3 options in tab "Lens Metrics"
      > Use `kubectl get -A pods` to check if the pods are up

#### 3. Test a Workload - Deployment
1. Create the template based on https://kubernetes.io/docs/concepts/workloads/controllers/deployment/
    ```yml
    # app.yml
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: nginx-app-deployment
    spec:
      selector:
        matchLabels:
          app: nginx
      replicas: 2 # tells deployment to run 2 pods matching the template
      template:
        metadata:
          labels:
            app: nginx
        spec:
          containers:
          - name: nginx
            image: nginx:latest ports:
            - containerPort: 80
    ```

2. Apply the template, `$ kubectl apply -f app.yml`, under the repo directory

#### 4. Test a Workload - Service
1. Create a service template
    ```yml
    # app-service.yml
    apiVersion: v1
    kind: Service
    metadata:
      name: nginx-app-service
    spec:
      selector:
        app: nginx
      ports:
        - protocol: TCP
          port: 80
          targetPort: 80
    ```

2. Apply the template, `$ kubectl apply -f app-service.yml`, under the repo directory

#### 5. Test a Workload - Ingress
> Ref: https://www.digitalocean.com/community/tutorials/how-to-set-up-an-nginx-ingress-on-digitalocean-kubernetes-using-helm#step-2-%E2%80%94-installing-the-kubernetes-nginx-ingress-controller

1. Add and install repo "ingress-nginx"
    ```sh
    $ helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
    $ helm repo update
    $ helm install nginx-ingress ingress-nginx/ingress-nginx --set controller.publishService.enabled=true
    ```

2. Create a template based on the [tutorial](https://www.digitalocean.com/community/tutorials/how-to-set-up-an-nginx-ingress-on-digitalocean-kubernetes-using-helm#step-3-%E2%80%94-exposing-the-app-using-an-ingress)
```yml
# app-ingress.yml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: app-ingress
  annotations:
    kubernetes.io/ingress.class: nginx
spec:
  rules:
  # change below to your domain
  - host: "k8s-challenge.chenghsuan.me"
    http:
      paths:
      - pathType: Prefix
        path: "/"
        backend:
          service:
            name: nginx-app-service
            port:
              number: 80
```

2. Apply the template, `$ kubectl apply -f app-ingress.yml`, under the repo directory
4. Use the IP address (of the load balancer) to create an A record in your DNS
5. Now the app is publicly accessible via http://k8s-challenge.chenghsuan.me/ (or your domain)

#### 6. Set up Secret Generator to Generate Secrets
> Ref: https://github.com/mittwald/kubernetes-secret-generator

```shell
$ helm repo add mittwald https://helm.mittwald.de
$ helm repo update
$ helm upgrade --install kubernetes-secret-generator mittwald/kubernetes-secret-generator
```

#### 7. Set up PostgreSQL Cluster with Kubegres
> Ref: https://www.kubegres.io/doc/getting-started.html

1. `$ kubectl apply -f https://raw.githubusercontent.com/reactive-tech/kubegres/v1.15/kubegres.yaml`
2. Generate passwords for master and replica postgres
    ```yml
    # postgres-secrets.yml
    apiVersion: v1
    kind: Secret
    metadata:
      name: postgres-master-secret
      annotations:
        secret-generator.v1.mittwald.de/autogenerate: password
    data: {}
    ---
    apiVersion: v1
    kind: Secret
    metadata:
      name: postgres-replica-secret
      annotations:
        secret-generator.v1.mittwald.de/autogenerate: password
    data: {}
    ```
    ```shell
    $ kubectl apply -f postgres-secrets.yml
    ```

3. Inspect the generated passwords from Lens
4. Create a cluster of Postgres instances
    ```yml
    # postgres.yml
    apiVersion: kubegres.reactive-tech.io/v1
    kind: Kubegres
    metadata:
      name: postgres
    spec:
      replicas: 3
      image: postgres:14.1
      database:
        size: 1Gi
      env:
        - name: POSTGRES_PASSWORD
          valueFrom:
            secretKeyRef:
              name: postgres-master-secret
              key: password
        - name: POSTGRES_REPLICATION_PASSWORD
          valueFrom:
            secretKeyRef:
              name: postgres-replica-secret
              key: password
    ```
    ```shell
    $ kubectl apply -f postgres.yml
    ```

#### 8. Create App Database via Postgres CLI
1. Generate app database secrets
    ```yml
    # app-secrets.yml
    apiVersion: v1
    kind: Secret
    metadata:
      name: app-postgres-secret
      annotations:
        secret-generator.v1.mittwald.de/autogenerate: password
        secret-generator.v1.mittwald.de/encoding: base64url # to prevent slash in the secret from breaking DATABASE_URL
    data: {}
    ```
    ```shell
    $ kubectl apply -f app-secrets.yml
    ```

2. Forward port of Postgres cluster; get the port from Lens
3. Copy raw value of `postgres-master-secret` and `app-postgres-secret`
4. Log into Postgres cluster via Postgres CLI
    ```shell
    $ psql -h localhost -U postgres -p port_from_lens
    # then paste the password from postgres-master-secret
    ```

5. Create user "app" (with password of `app-postgres-secret` raw value) and database "app_prod"
    ```sql
    CREATE USER app WITH PASSWORD 'APPPOSTGRESSECRETVALUEFROMLENS';
    CREATE DATABASE app_prod OWNER app;

    # verify change
    \l

    # quit
    quit
    ```

#### 9. Set up Front-Facing App
1. Create a board app with Elixir Phoenix (example in dir `phx-docker-app`)
2. Configure app\*.yml for the new board app
3. Apply the changes
    ```shell
    $ kubectl apply app-secrets.yml
    $ kubectl apply app.yml
    $ kubectl apply app-service.yml
    $ kubectl apply app-ingress.yml
    ```
4. Open pod shell in one of the board-app-deployment pod and `$ ./bin/migrate`
5. Open the app http://k8s-challenge.chenghsuan.me/ (or your domain)
