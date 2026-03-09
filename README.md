# k1x

Reproducible Kubernetes environments for development and testing powered by Nix.

k1x is like docker-compose for Kubernetes. Create a `k1x.nix` file describing your setup, run `k1x up` and you are good to go.

No Kubernetes knowledge required.

**All dependencies managed by Nix**

k1x manages all dependencies using Nix, so you don't have to worry about installing Helm, k3d, kubectl or any other kubernetes developer tool.

### Getting started

Running `k1x init` generates a `k1x.nix` containing:

```nix
{ ... }:

{
  version = "1.0";
  cluster = {
    name = "mycluster";
    provider = "k3d";
    nativeConfig = {
      apiVersion = "k3d.io/v1alpha5";
      kind = "Simple";
      servers = 1;
      agents = 2;
      ports = [{
        port = "8080:80";
        nodeFilters = [ "loadbalancer" ];
      }];
    };
  };
}
```

And `k1x up` starts the development cluster.

### Usage

- `k1x init`: Scaffold `k1x.nix`
- `k1x up`: Starts development cluster
- `k1x version`: Outputs current version

### License

This project is licensed under the [MIT License](LICENSE).
