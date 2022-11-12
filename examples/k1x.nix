{ ... }:

{
  version = "1.0";
  cluster = {
    name = "mycluster";
    provider = "k3d";
    nativeConfig = {
      apiVersion = "k3d.io/v1alpha2";
      kind = "Simple";
      servers = 1;
      agents = 2;
      image = "rancher/k3s:v1.22.9-k3s1";
      ports = [{
        port = "8080:80";
        nodeFilters = [ "loadbalancer" ];
      }];
    };
  };
}
