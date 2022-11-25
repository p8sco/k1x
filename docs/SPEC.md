# k1x.nix specification

A `k1x.nix` is a declarative file in Nix language. It is used to create an ephemeral Kubernetes cluster that is close to production.

## Cluster definition

### `cluster`

Describe the cluster provisioner.

`provider`

Currently, only `k3d` is supported as value.

`name`

An arbitrary name for the cluster.

`nativeConfig`

Provider specific configurations.

For `k3d` you can find the reference here: https://k3d.io/v5.3.0/usage/configfile/

**k3d example**

```nix
{ ... }: {
  cluster = {
    name = "mycluster";
    provider = "k3d";
    # https://k3d.io/v5.0.0/usage/configfile/
    nativeConfig = {
      apiVersion = "k3d.io/v1alpha3";
      kind = "Simple";
      name = "mycluster";
      servers = 1;
      agents = 2;
      image = "rancher/k3s:v1.20.4-k3s1";
      ports = [{
        port = "8080:80";
        nodeFilters = [ "loadbalancer" ];
      }];
    };
  };
}
```

## Workloads

Specify one or more workloads to be provided with k1x.

### Example of a workload specification

```nix
{ ... }:

{
  workloads = [{
    name = "k8s-dashboard";
    namespace = "observability";
    sources = [
      {
        type = "helm";
        ref = "https://kubernetes.github.io/dashboard";
        chart = "kubernetes-dashboard";
        parameters = [{
          name = "ingress.enabled";
          value = true;
        }];
      }
      {
        type = "file";
        content = ''
          apiVersion: rbac.authorization.k8s.io/v1
          kind: ClusterRoleBinding
          metadata:
            name: kubernetes-dashboard
            namespace: kubernetes-dashboard
          roleRef:
            apiGroup: rbac.authorization.k8s.io
            kind: ClusterRole
            name: cluster-admin
          subjects:
            - kind: ServiceAccount
              name: kubernetes-dashboard
              namespace: mynamespace
        '';
      }
    ];
  }];
}
```
