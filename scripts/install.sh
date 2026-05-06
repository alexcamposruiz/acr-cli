#!/usr/bin/env sh
set -eu

OWNER="alexcamposruiz"
REPO="acr-cli"
BINARY="acrcli"
INSTALL_DIR="${INSTALL_DIR:-/usr/local/bin}"
VERSION="${VERSION:-latest}"

need() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "missing required command: $1" >&2
    exit 1
  }
}

detect_os() {
  case "$(uname -s)" in
    Darwin) echo "darwin" ;;
    Linux) echo "linux" ;;
    *)
      echo "unsupported OS: $(uname -s)" >&2
      exit 1
      ;;
  esac
}

detect_arch() {
  case "$(uname -m)" in
    x86_64 | amd64) echo "amd64" ;;
    arm64 | aarch64) echo "arm64" ;;
    *)
      echo "unsupported architecture: $(uname -m)" >&2
      exit 1
      ;;
  esac
}

resolve_version() {
  if [ "$VERSION" != "latest" ]; then
    echo "$VERSION"
    return
  fi

  curl -fsSLI -o /dev/null -w '%{url_effective}' "https://github.com/${OWNER}/${REPO}/releases/latest" |
    sed 's#.*/##'
}

need curl
need tar
need sed

os="$(detect_os)"
arch="$(detect_arch)"
tag="$(resolve_version)"
archive="${REPO}_${os}_${arch}.tar.gz"
url="https://github.com/${OWNER}/${REPO}/releases/download/${tag}/${archive}"
tmpdir="$(mktemp -d)"

cleanup() {
  rm -rf "$tmpdir"
}
trap cleanup EXIT INT TERM

curl -fsSL "$url" -o "$tmpdir/$archive"
tar -xzf "$tmpdir/$archive" -C "$tmpdir" "$BINARY"

mkdir -p "$INSTALL_DIR"
mv "$tmpdir/$BINARY" "$INSTALL_DIR/$BINARY"
chmod 0755 "$INSTALL_DIR/$BINARY"

echo "installed $BINARY $tag to $INSTALL_DIR/$BINARY"
