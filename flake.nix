{
  description = "yt-dlp master, packaged for Nix";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      pin = builtins.fromJSON (builtins.readFile ./pin.json);
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
    in
    {
      packages = forAllSystems (pkgs: {
        yt-dlp = pkgs.yt-dlp.overrideAttrs (prev: {
          version = pin.version;
          src = pkgs.fetchFromGitHub {
            owner = "yt-dlp";
            repo = "yt-dlp";
            inherit (pin) rev hash;
          };
          # Upstream master still carries the last release's version; stamp the
          # pin so `yt-dlp --version` identifies the synced commit.
          postPatch = (prev.postPatch or "") + ''
            ${pkgs.gnused}/bin/sed -E -i \
              -e "s/^__version__ = '.*'/__version__ = '${pin.version}'/" \
              -e "s/^_pkg_version = '.*'/_pkg_version = '${pin.version}'/" \
              -e "s/^CHANNEL = '.*'/CHANNEL = 'master'/" \
              yt_dlp/version.py
          '';
        });
        default = self.packages.${pkgs.stdenv.hostPlatform.system}.yt-dlp;
      });
    };
}
