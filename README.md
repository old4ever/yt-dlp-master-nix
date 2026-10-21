# yt-dlp master for Nix

Daily snapshot of [yt-dlp](https://github.com/yt-dlp/yt-dlp) `master`, built with
nixpkgs, pushed to a self-hosted [Attic](https://github.com/zhaofengli/attic)
binary cache.

## Use

```nix
{
  inputs.yt-dlp-master.url = "github:old4ever/yt-dlp-master-nix";
  # ...
}
```

Substituter (public cache):

```nix
nix.settings = {
  substituters = [ "https://attic.cloud.dmytros.dev/cache" ];
  trusted-public-keys = [ "cache:dPtLerJjZ/TCkK4fFdrOKUmUMiKB1iNzbw/Imx6HCzc=" ];
};
```

```sh
nix build github:old4ever/yt-dlp-master-nix#yt-dlp
nix run github:old4ever/yt-dlp-master-nix
```

## How it works

- `pin.json` holds the upstream revision, its source hash, and the version
  stamped into `yt_dlp/version.py` (upstream master keeps reporting the last
  release).
- `.github/workflows/sync.yml` runs daily: resolves `yt-dlp/yt-dlp` `master`,
  prefetches the archive hash, builds `.#yt-dlp`, pushes the result to the
  `cache` on `attic.cloud.dmytros.dev`, then commits `pin.json`.
- It needs one repository secret: `ATTIC_TOKEN`, an Attic token with `push` on
  `cache`. Without a change upstream the job exits without building.

## Files

| file | purpose |
|---|---|
| `flake.nix` | overrides nixpkgs `yt-dlp` with the pinned source |
| `pin.json` | upstream rev, source hash, stamped version |
| `.github/workflows/sync.yml` | daily sync, build, cache push |
