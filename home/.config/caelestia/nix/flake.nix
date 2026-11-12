{
  description = "Caelestia CLI + shell with local patches";

  # Pinned to the installed revision so only the shell's QML gets rebuilt; bump it to upgrade.
  inputs.cli.url = "github:caelestia-dots/cli/fdb3e47038c77ec8e7bb6010ffbcae00501d420b";

  outputs = {cli, ...}: let
    system = "x86_64-linux";
    shell = cli.inputs.caelestia-shell.packages.${system}.default.overrideAttrs (old: {
      patches = (old.patches or []) ++ [./workspace-attention.patch ./bar-clock.patch ./bar-app-name.patch ./notif-icon.patch ./hover-click.patch ./bt-pairing.patch];
    });
  in {
    packages.${system}.default = cli.packages.${system}.with-shell.override {caelestia-shell = shell;};
  };
}
