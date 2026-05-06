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

verify_checksum() {
  checksums="$1"
  archive_path="$2"
  archive_name="$3"

  expected="$(awk -v archive="$archive_name" '$2 == archive {print $1; exit}' "$checksums")"
  if [ -z "$expected" ]; then
    echo "checksum not found for $archive_name" >&2
    exit 1
  fi

  if command -v sha256sum >/dev/null 2>&1; then
    actual="$(sha256sum "$archive_path" | awk '{print $1}')"
  elif command -v shasum >/dev/null 2>&1; then
    actual="$(shasum -a 256 "$archive_path" | awk '{print $1}')"
  else
    echo "missing required command: sha256sum or shasum" >&2
    exit 1
  fi

  if [ "$actual" != "$expected" ]; then
    echo "checksum mismatch for $archive_name" >&2
    echo "expected: $expected" >&2
    echo "actual:   $actual" >&2
    exit 1
  fi
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
need awk

os="$(detect_os)"
arch="$(detect_arch)"
tag="$(resolve_version)"
archive="${REPO}_${os}_${arch}.tar.gz"
url="https://github.com/${OWNER}/${REPO}/releases/download/${tag}/${archive}"
checksums_url="https://github.com/${OWNER}/${REPO}/releases/download/${tag}/checksums.txt"
tmpdir="$(mktemp -d)"

cleanup() {
  rm -rf "$tmpdir"
}
trap cleanup EXIT INT TERM

curl -fsSL "$url" -o "$tmpdir/$archive"
curl -fsSL "$checksums_url" -o "$tmpdir/checksums.txt"
verify_checksum "$tmpdir/checksums.txt" "$tmpdir/$archive" "$archive"
tar -xzf "$tmpdir/$archive" -C "$tmpdir" "$BINARY"

mkdir -p "$INSTALL_DIR"
mv "$tmpdir/$BINARY" "$INSTALL_DIR/$BINARY"
chmod 0755 "$INSTALL_DIR/$BINARY"

echo "installed $BINARY $tag to $INSTALL_DIR/$BINARY"
