{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils, ... }@inputs: let
    hostname = "nammu";
  in {
    nixosConfigurations.${hostname} = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      modules = [self.nixosModule];
    };
    nixosModule = import ./configuration.nix;
  } // (flake-utils.lib.eachSystem flake-utils.lib.defaultSystems (system: let
    pkgs = nixpkgs.legacyPackages."${system}";
    env = ''
      export NIX_PATH="nixpkgs=${nixpkgs}"
      export SSH_USER=root
    '';
  in {
    devShell = pkgs.mkShell {
      packages = [ pkgs.morph ];
      shellHook = env;
    };
    defaultApp = {
      type = "app";
      program = "${pkgs.writeShellScript "deploy-${hostname}" ''
        ${env}
        ${pkgs.morph}/bin/morph deploy ${self}/morph.nix switch
      ''}";
    };
  }));
}
