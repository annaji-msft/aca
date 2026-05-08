#!/bin/sh
set -e

REPO="annaji-msft/aca"
BINARY_NAME="aca"
INSTALL_DIR="/usr/local/bin"

# Allow overriding version; default to latest
VERSION="${ACA_VERSION:-latest}"

detect_platform() {
    OS="$(uname -s)"
    ARCH="$(uname -m)"

    case "$OS" in
        Linux)  OS_TAG="linux" ;;
        Darwin) OS_TAG="osx" ;;
        *)      echo "Error: Unsupported OS: $OS"; exit 1 ;;
    esac

    case "$ARCH" in
        x86_64|amd64)  ARCH_TAG="x64" ;;
        aarch64|arm64) ARCH_TAG="arm64" ;;
        *)             echo "Error: Unsupported architecture: $ARCH"; exit 1 ;;
    esac

    PLATFORM="${OS_TAG}-${ARCH_TAG}"
}

get_download_url() {
    if [ "$VERSION" = "latest" ]; then
        URL="https://github.com/${REPO}/releases/latest/download/${BINARY_NAME}-${PLATFORM}.tar.gz"
    else
        URL="https://github.com/${REPO}/releases/download/${VERSION}/${BINARY_NAME}-${VERSION}-${PLATFORM}.tar.gz"
    fi
}

install() {
    detect_platform
    echo "Detected platform: ${PLATFORM}"

    get_download_url
    echo "Downloading ${BINARY_NAME} from ${URL}..."

    TMP_DIR="$(mktemp -d)"
    trap 'rm -rf "$TMP_DIR"' EXIT

    curl -fsSL "$URL" -o "${TMP_DIR}/${BINARY_NAME}.tar.gz"
    tar -xzf "${TMP_DIR}/${BINARY_NAME}.tar.gz" -C "$TMP_DIR"

    # Install to INSTALL_DIR (try sudo if needed)
    if [ -w "$INSTALL_DIR" ]; then
        cp "${TMP_DIR}/${BINARY_NAME}" "${INSTALL_DIR}/${BINARY_NAME}"
        chmod +x "${INSTALL_DIR}/${BINARY_NAME}"
    else
        echo "Installing to ${INSTALL_DIR} (requires sudo)..."
        sudo cp "${TMP_DIR}/${BINARY_NAME}" "${INSTALL_DIR}/${BINARY_NAME}"
        sudo chmod +x "${INSTALL_DIR}/${BINARY_NAME}"
    fi

    echo ""
    echo "${BINARY_NAME} installed successfully to ${INSTALL_DIR}/${BINARY_NAME}"
    echo "Run '${BINARY_NAME} --help' to get started."
}

install
