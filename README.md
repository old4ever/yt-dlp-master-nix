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
- `.github/workflows/sync.yml` runs daily in one job that chains three
  composite actions, so an unchanged day costs one short job and no Nix setup:
  1. `update-pin` resolves `master` with `curl`/`jq`, compares it with
     `pin.json`, and only then installs Nix, prefetches the source hash and
     writes the pin.
  2. `build-push` builds `.#yt-dlp` and pushes the outputs to the `cache` on
     `attic.cloud.dmytros.dev`.
  3. `commit-pin` commits `pin.json` — only after the build and push succeeded.
- It needs one repository secret: `ATTIC_TOKEN`, an Attic token with `push` on
  `cache`. `timeout-minutes: 20` bounds a runaway run.


## Files

| file | purpose |
|---|---|
| `flake.nix` | overrides nixpkgs `yt-dlp` with the pinned source |
| `pin.json` | upstream rev, source hash, stamped version |
| `.github/workflows/sync.yml` | schedules the three jobs |
| `.github/actions/update-pin` | resolve + prefetch + write `pin.json` |
| `.github/actions/build-push` | build and push to Attic |
| `.github/actions/commit-pin` | commit and push `pin.json` |

