{
  description = "Messaging Service";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        pname = "messaging-service";
        version = "1.0.0";

        erlang = pkgs.erlang_28;
        elixir = pkgs.elixir_1_18.override { inherit erlang; };
        src = ./.;
      in
      {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            erlang
            elixir
          ];

          shellHook = ''
            export MIX_HOME=$PWD/.nix-mix
            export HEX_HOME=$PWD/.nix-hex
            export PATH=$MIX_HOME/bin:$HEX_HOME/bin:$PATH

            mix local.hex --force --if-missing
            mix local.rebar --force --if-missing
          '';
        };
      });
}
