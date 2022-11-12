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

For `k3d` the reference is here: https://k3d.io/v5.3.0/usage/configfile/

**k3d example**

```nix
[...]
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
[...]
```
