{ ... }:

{
  version = "1.0";
  cluster = {
    name = "mycluster";
    provider = "k3d";
    # https://k3d.io/stable/usage/configfile/
    nativeConfig = {
      apiVersion = "k3d.io/v1alpha5";
      kind = "Simple";
      name = "mycluster";
      servers = 1;
      agents = 2;
      ports = [{
        port = "8080:80";
        nodeFilters = [ "loadbalancer" ];
      }];
    };
  };
}
