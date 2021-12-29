Nixos configuration and deployment tooling for my Octoprint server, "nammu". This repo is a nix-flake which exposes the system configuration, a devshell from which you can deploy and an app that will run the deployment.

Being a flake, you need Nix 2.4 or later. This is the only prerequisite.

# Deployment

Run the following from your shell:

```shell
nix run github:frogamic/octonix
```
