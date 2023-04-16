{ sources ? import ./nix/sources.nix
, pkgs ? import sources.nixpkgs { }
}:

with pkgs;
let
  elixir = beam.packages.erlangR23.elixir_1_12;
in
buildEnv {
  name = "builder";
  paths = [
    elixir
    nodejs-16_x
    # postgresql_12
  ];
}
