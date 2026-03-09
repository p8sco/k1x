# k1x

Reproducible Kubernetes environments for development and testing powered by Nix.

k1x is like docker-compose for Kubernetes. Create a `k1x.nix` file describing your setup, run `k1x up` and you are good to go.

No Kubernetes knowledge required.

**All dependencies managed by Nix**

k1x manages all dependencies using Nix, so you don't have to worry about installing Helm, k3d, kubectl or any other kubernetes developer tool.

## Prerequisites

- [Nix](https://nixos.org/download/) with [flakes enabled](https://wiki.nixos.org/wiki/Flakes)

## Installation

Run k1x directly without installing:

```sh
nix run github:p8sco/k1x -- init
nix run github:p8sco/k1x -- up
```

Or install it to your profile:

```sh
nix profile install github:p8sco/k1x
```

## Getting started

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

## Usage

- `k1x init [TARGET]`: Scaffold `k1x.nix` in the current or target directory
- `k1x up`: Start the development cluster in foreground
- `k1x version`: Output current version

## Building locally

Clone the repository and build with Nix:

```sh
git clone https://github.com/p8sco/k1x.git
cd k1x
nix build
```

The built binary will be available at `./result/bin/k1x`.

To build and run in one step:

```sh
nix run .
```

## Development

Enter the development shell which includes k1x, watchexec, nixpkgs-fmt, and shellcheck:

```sh
nix develop
```

Format Nix files:

```sh
nix fmt
```

Run shellcheck on the k1x script after building:

```sh
shellcheck ./result/bin/k1x
```

## Supported platforms

- `x86_64-linux`
- `aarch64-linux`
- `x86_64-darwin`
- `aarch64-darwin`

## License

This project is licensed under the [MIT License](LICENSE).
