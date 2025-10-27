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

        mixFodDeps = (pkgs.beamPackages.fetchMixDeps {
          pname = "${pname}-deps";
          inherit src version;
          sha256 = "sha256-3v9dVukwJNK++N1UKOx/34OjVI+/0YQkKkFjqayYvlc=";

          nativeBuildInputs = with pkgs; [
            cmake
            gnumake
            gcc
          ];

          SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
          GIT_SSL_CAINFO = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
        }).overrideAttrs (old: {
          __noChroot = true;
        });
      in
      {
        packages = {
          default = pkgs.beamPackages.mixRelease {
            inherit pname version elixir src mixFodDeps;

            MIX_ENV = "prod";

            nativeBuildInputs = with pkgs; [
              cmake
              gnumake
              gcc
            ];

            postBuild = ''
              mix phx.digest
            '';
          };

          docker = pkgs.dockerTools.buildLayeredImage {
            name = pname;
            tag = version;
            contents = [
              self.packages.${system}.default
              pkgs.cacert
              pkgs.bash
              pkgs.coreutils
            ];
            config = {
              Cmd = [ "${self.packages.${system}.default}/bin/${pname}" "start" ];
              Env = [
                "SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
                "LANG=C.UTF-8"
                "MIX_ENV=prod"
              ];
              ExposedPorts = {
                "4000/tcp" = { };
              };
            };
          };
        };

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
