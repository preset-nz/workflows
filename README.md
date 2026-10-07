# workflows

Reusable GitHub Actions workflows for preset.nz code repos. One `check.yml` sets up a repo's own toolchain and runs `just check`, so CI is the same everywhere and a tool pin changes in one place.

CI runs `just check` and nothing else. Whatever `check` needs belongs in the repo's justfile, not in the workflow call.

## Use it

A package (facets): pnpm only, detected from `package.json`.

```yaml
name: CI
on: { push: { branches: [main] }, pull_request: {} }
permissions: { contents: read }
jobs:
  check:
    uses: preset-nz/workflows/.github/workflows/check.yml@<tag-or-sha>
```

An app (Shard): pnpm and Rust, plus Tauri's Linux libraries.

```yaml
name: CI
on: { push: { branches: [main] }, pull_request: {} }
permissions: { contents: read }
jobs:
  check:
    uses: preset-nz/workflows/.github/workflows/check.yml@<tag-or-sha>
    with: { tauri: true }
```

A repo that adopts `check.yml` deletes its copied `licences.yml`: `check.yml` installs `preset-compliance` (pinned here, once) and `just check` calls `just licences`.

## What it does

1. Checks out the repo.
2. With `package.json`: installs pnpm at the version in `packageManager`, Node 24 with the pnpm store cached, then `pnpm install --frozen-lockfile`.
3. With `rust-toolchain.toml`, or a `Cargo.toml` within two directories of the root: installs Rust through rustup (the file's channel and components, else stable) with clippy and rustfmt, adds `rust-targets`, and caches with `Swatinem/rust-cache`.
4. Installs `just`, and `preset-compliance` (binary only).
5. Runs `just check`.

It has `permissions: contents: read`, and a newer push to the same ref cancels the older run.

## Inputs

| Input | Type | Default | What it does |
|---|---|---|---|
| `runs-on` | string | `ubuntu-latest` | Runner label. A calling job that uses a workflow can't set its own runner. |
| `rust-targets` | string | empty | Extra rustup targets, space-separated, e.g. `wasm32-unknown-unknown` (Fault). |
| `wasm-pack` | boolean | `false` | Installs `wasm-pack` (Fault). |
| `tauri` | boolean | `false` | Installs the Linux system libraries a Tauri 2 app needs to compile: webkit2gtk 4.1, GTK 3, ayatana appindicator, librsvg, OpenSSL, libxdo, ALSA headers. |
| `uv` | boolean | `false` | Installs uv (Oblique's sidecar: ruff, pytest). |

## Toolchains come from the repo

- pnpm: `"packageManager": "pnpm@11.1.1"` in `package.json`.
- Rust: `rust-toolchain.toml` with `channel = "stable"` and the components the repo uses. The version floats, so CI can run ahead of a machine that hasn't run `rustup update`.

## Versioning

Callers pin a tag or a full commit SHA, never a branch. The pilot repos call a fixed tag. A moving `v1` appears only once the pilot is green, because a bad `v1` breaks every repo at once.

Third-party actions inside `check.yml` are pinned by commit SHA with the tag in a comment. `preset-nz/compliance` is pinned by tag instead: the action picks which binary to download from its own ref, and a SHA would fall through to the latest release.

## Working on this repo

```
just prep    # print tool versions
just check   # actionlint and zizmor over the workflows
```

Releases: `just release-preview`, then `just release`. knope reads the version from the latest `vX.Y.Z` tag, since the repo has no package manifest.

MIT licensed.
