#!/usr/bin/env bash
set -e

# Fukushu universal install script
# Usage: curl -sSL https://raw.githubusercontent.com/HITMAN949/fukushu-cli/main/install.sh | bash

REPO="HITMAN949/fukushu-cli"
BIN_NAME="fukushu"
INSTALL_DIR="/usr/local/bin"
LOG_FILE=$(mktemp)

GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

cat << "EOF"
    ______      __               __         
   / ____/_  __/ /____  _______/ /_  __  __
  / /_  / / / / //_/ / / / ___/ __ \/ / / /
 / __/ / /_/ / ,< / /_/ (__  ) / / / /_/ / 
/_/    \__,_/_/|_|\__,_/____/_/ /_/\__,_/  
EOF
echo -e "${CYAN}   Unified Security Scanner Ecosystem${NC}\n"

echo -e "${BLUE}[*]${NC} Initializing automated environment setup..."

OS="$(uname -s | tr '[:upper:]' '[:lower:]')"
ARCH="$(uname -m)"

if [ "$ARCH" = "x86_64" ]; then ARCH="x86_64"
elif [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then ARCH="arm64"
else echo -e "${RED}[!]${NC} Unsupported architecture: $ARCH"; exit 1; fi

if [ "$OS" = "linux" ]; then OS_TITLE="Linux"
elif [ "$OS" = "darwin" ]; then OS_TITLE="Darwin"
else echo -e "${RED}[!]${NC} Unsupported OS: $OS"; exit 1; fi

echo -e "${GREEN}[✔]${NC} Detected Environment: ${OS_TITLE} (${ARCH})"

echo -ne "${BLUE}[*]${NC} Downloading Core Engine (fukushu)... "
LATEST_URL=$(curl -s https://api.github.com/repos/$REPO/releases/latest | grep "browser_download_url" | grep -i "${OS_TITLE}_${ARCH}.tar.gz" | cut -d '"' -f 4)
TMP_DIR=$(mktemp -d)
curl -sL "$LATEST_URL" | tar xz -C "$TMP_DIR" >> "$LOG_FILE" 2>&1
sudo mv "$TMP_DIR/$BIN_NAME" "$INSTALL_DIR/" >> "$LOG_FILE" 2>&1
sudo chmod +x "$INSTALL_DIR/$BIN_NAME"
echo -e "${GREEN}Done${NC}"

echo -ne "${BLUE}[*]${NC} Installing Trivy (IaC & Containers)... "
curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sudo sh -s -- -b "$INSTALL_DIR" >> "$LOG_FILE" 2>&1
echo -e "${GREEN}Done${NC}"

echo -ne "${BLUE}[*]${NC} Installing Gitleaks (Secrets)... "
GITLEAKS_ARCH=$ARCH
if [ "$ARCH" = "x86_64" ]; then GITLEAKS_ARCH="x64"; fi
GITLEAKS_OS=$(echo "$OS" | tr '[:upper:]' '[:lower:]')
GITLEAKS_TAG=$(curl -sI https://github.com/gitleaks/gitleaks/releases/latest | grep -i location | awk -F '/' '{print $NF}' | tr -d '\r')
if [ -n "$GITLEAKS_TAG" ]; then
    GITLEAKS_VERSION=${GITLEAKS_TAG#v}
    GITLEAKS_URL="https://github.com/gitleaks/gitleaks/releases/download/${GITLEAKS_TAG}/gitleaks_${GITLEAKS_VERSION}_${GITLEAKS_OS}_${GITLEAKS_ARCH}.tar.gz"
    TMP_GIT=$(mktemp -d)
    curl -sL "$GITLEAKS_URL" | tar xz -C "$TMP_GIT" >> "$LOG_FILE" 2>&1
    sudo mv "$TMP_GIT/gitleaks" "$INSTALL_DIR/" >> "$LOG_FILE" 2>&1
    sudo chmod +x "$INSTALL_DIR/gitleaks"
    rm -rf "$TMP_GIT"
    echo -e "${GREEN}Done${NC}"
else
    echo -e "${RED}Failed${NC}"
fi

echo -ne "${BLUE}[*]${NC} Installing OSV-Scanner (Dependencies)... "
OSV_ARCH=$ARCH
if [ "$ARCH" = "x86_64" ]; then OSV_ARCH="amd64"; fi
OSV_OS=$(echo "$OS" | tr '[:upper:]' '[:lower:]')
OSV_TAG=$(curl -sI https://github.com/google/osv-scanner/releases/latest | grep -i location | awk -F '/' '{print $NF}' | tr -d '\r')
if [ -n "$OSV_TAG" ]; then
    OSV_URL="https://github.com/google/osv-scanner/releases/download/${OSV_TAG}/osv-scanner_${OSV_OS}_${OSV_ARCH}"
    sudo curl -sL "$OSV_URL" -o "$INSTALL_DIR/osv-scanner" >> "$LOG_FILE" 2>&1
    sudo chmod +x "$INSTALL_DIR/osv-scanner"
    echo -e "${GREEN}Done${NC}"
else
    echo -e "${RED}Failed${NC}"
fi

echo -ne "${BLUE}[*]${NC} Installing Semgrep (SAST)... "
if command -v pip3 &> /dev/null; then
    if pip3 install --help | grep -q break-system-packages; then
        sudo pip3 install semgrep --ignore-installed --break-system-packages >> "$LOG_FILE" 2>&1
    else
        sudo pip3 install semgrep --ignore-installed >> "$LOG_FILE" 2>&1
    fi
    echo -e "${GREEN}Done${NC}"
elif command -v pip &> /dev/null; then
    if pip install --help | grep -q break-system-packages; then
        sudo pip install semgrep --ignore-installed --break-system-packages >> "$LOG_FILE" 2>&1
    else
        sudo pip install semgrep --ignore-installed >> "$LOG_FILE" 2>&1
    fi
    echo -e "${GREEN}Done${NC}"
elif command -v brew &> /dev/null; then
    brew install semgrep >> "$LOG_FILE" 2>&1
    echo -e "${GREEN}Done${NC}"
else
    echo -e "${RED}Failed (Pip not found)${NC}"
fi

echo -ne "${BLUE}[*]${NC} Installing Ruff (Python Linter)... "
if command -v pip3 &> /dev/null; then
    if pip3 install --help | grep -q break-system-packages; then
        sudo pip3 install ruff --ignore-installed --break-system-packages >> "$LOG_FILE" 2>&1
    else
        sudo pip3 install ruff --ignore-installed >> "$LOG_FILE" 2>&1
    fi
    echo -e "${GREEN}Done${NC}"
else
    echo -e "${RED}Failed (Pip3 not found)${NC}"
fi

echo -ne "${BLUE}[*]${NC} Installing ESLint (JS/TS Linter)... "
if command -v npm &> /dev/null; then
    sudo npm install -g eslint >> "$LOG_FILE" 2>&1
    echo -e "${GREEN}Done${NC}"
else
    echo -e "${RED}Failed (npm not found)${NC}"
fi

echo -ne "${BLUE}[*]${NC} Installing golangci-lint (Go Linter)... "
curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sudo sh -s -- -b "$INSTALL_DIR" latest >> "$LOG_FILE" 2>&1
echo -e "${GREEN}Done${NC}"

echo -ne "${BLUE}[*]${NC} Installing Ollama (Local AI Agent Provider)... "
if command -v ollama &> /dev/null; then
    echo -e "${GREEN}Already installed${NC}"
else
    curl -fsSL https://ollama.com/install.sh | sh >> "$LOG_FILE" 2>&1
    echo -e "${GREEN}Done${NC}"
fi

echo -ne "${BLUE}[*]${NC} Fetching Go Development Dependencies (TUI & AI)... "
if command -v go &> /dev/null; then
    go get github.com/charmbracelet/bubbletea@latest >> "$LOG_FILE" 2>&1
    go get github.com/charmbracelet/bubbles@latest >> "$LOG_FILE" 2>&1
    go get github.com/charmbracelet/lipgloss@latest >> "$LOG_FILE" 2>&1
    go get github.com/tmc/langchaingo@latest >> "$LOG_FILE" 2>&1
    go get github.com/tmc/langchaingo/llms/ollama@latest >> "$LOG_FILE" 2>&1
    go get github.com/tmc/langchaingo/llms/openai@latest >> "$LOG_FILE" 2>&1
    go get github.com/tmc/langchaingo/llms/anthropic@latest >> "$LOG_FILE" 2>&1
    go get github.com/tmc/langchaingo/llms/googleai@latest >> "$LOG_FILE" 2>&1
    echo -e "${GREEN}Done${NC}"
else
    echo -e "${BLUE}Skipped (Go not installed)${NC}"
fi

rm -rf "$TMP_DIR"
rm -f "$LOG_FILE"

echo -e "\n${GREEN}[✔] Installation Complete!${NC}"
echo -e "    Run ${CYAN}fukushu scan .${NC} to start scanning."
echo -e "    Run ${CYAN}fukushu ask \"scan the src directory\"${NC} to use the AI Agent."
