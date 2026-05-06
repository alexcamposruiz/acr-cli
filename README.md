# acr-cli

`acr-cli` is a small Go CLI repository wired for GitHub Actions, GitHub Releases, GoReleaser, and a separate Homebrew tap.

## Install

```sh
brew tap alexcamposruiz/tap
brew install acr-cli
```

or:

```sh
curl -fsSL https://raw.githubusercontent.com/alexcamposruiz/acr-cli/main/scripts/install.sh | sh
```

The installer verifies the downloaded release archive against the published `checksums.txt` before installing.

## Use

```sh
acrcli doctor
acrcli version
```

## Release

Create the tap repository at `github.com/alexcamposruiz/homebrew-tap`, then add this Actions secret to the `acr-cli` repository:

```text
HOMEBREW_TAP_GITHUB_TOKEN
```

The token needs `Contents: Read and Write` on `homebrew-tap`.

To release:

```sh
git tag v0.1.0
git push origin main --tags
```

The tag workflow publishes GitHub release artifacts, checksums, and updates `Formula/acr-cli.rb` in `homebrew-tap`.
