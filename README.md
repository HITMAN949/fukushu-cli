<p align="center">
  <h1 align="center">復讐 fukushu</h1>
  <p align="center">
    <strong>Unified security scanner CLI & Autonomous AI Remediation Agent</strong>
  </p>
  <p align="center">
    One binary. Seven scanners. Zero runtime dependencies. Fully autonomous AI.
  </p>
</p>

<p align="center">
  <a href="#installation">Installation</a> •
  <a href="#quick-start">Quick Start</a> •
  <a href="#the-tui">The TUI</a> •
  <a href="#autonomous-ai-agent">Autonomous AI Agent</a> •
  <a href="#scanners">Scanners</a>
</p>

---

**fukushu v1.0.0** is the ultimate AppSec ecosystem. It wraps **seven** battle-tested open-source scanners into a single binary, normalizes their output, and unleashes an **Autonomous AI Agent** that can read your code, find vulnerabilities, and automatically write patches to your disk.

## Why fukushu?

| Feature | Description |
|---|---|
| **7 Scanners = 1 Format** | SAST, secrets, IaC, containers, and linting all normalized into one finding schema or SARIF. |
| **Interactive TUI** | Built on Bubble Tea. Ditch the static logs and interact with your security scans in a beautiful terminal UI. |
| **Autonomous Remediation** | Run `fukushu fix` and watch the AI Agent scan, analyze, and patch your code live on disk. |
| **Deep-Audit Tools** | The AI has access to `security_audit_tool`, `code_review_tool`, and `audit_integrations_tool` for deep heuristic analysis beyond standard scanners. |
| **Local LLM Support** | Air-gapped? No problem. Full support for local **Ollama** models, plus cloud providers (OpenAI, Gemini, Anthropic). |

## Scanners Included

The [install script](#installation) handles installing all of these automatically:

- **Security:** [Semgrep] (SAST), [Gitleaks] (Secrets), [osv-scanner] (Dependencies), [Trivy] (IaC/Containers)
- **Code Quality:** [Ruff] (Python), [ESLint] (JS/TS), [golangci-lint] (Go)

## Installation

### The Easy Way (Linux / macOS)

Run this quick install script to automatically download and install `fukushu` globally. **It will also automatically download and install all 7 scanners and Ollama for you!**

```bash
curl -sSL https://raw.githubusercontent.com/HITMAN949/fukushu-cli/main/install.sh | sudo bash
```

### Windows & Manual Downloads

Head over to the [Releases page](https://github.com/HITMAN949/fukushu-cli/releases) and download the `.zip` for Windows, or the `.tar.gz` for Linux/macOS.

## Quick Start

### 1. The TUI Dashboard
Running `fukushu` with no arguments launches the interactive Bubble Tea dashboard. You can run scans, chat with the AI, and trigger Auto-Fixes directly from the sidebar.
```bash
fukushu
```

### 2. Autonomous Remediation
Unleash the AI to automatically patch your codebase. It will scan, read vulnerable files, and write secure patches back to disk.
```bash
fukushu fix .
```

### 3. Chat with the AI
Ask the AI to perform a specific audit using its deep-reasoning tools.
```bash
fukushu ask "Run a security audit on src/auth.go"
```

### 4. Standard CLI Scanning
```bash
# Scan the current directory with all enabled scanners
fukushu scan .

# Scan with JSON output, fail on high+ severity
fukushu scan . --format json --fail-on high

# Export to SARIF for GitHub Advanced Security
fukushu scan . --format sarif --output results.sarif
```

## AI Configuration

fukushu uses **Ollama** by default for total privacy, but supports OpenAI, Gemini, and Anthropic. Create a `.fukushu.yml` in your workspace to configure it:

```yaml
version: 1

agent:
  provider: ollama       # ollama | openai | gemini | anthropic
  model: qwen3.5:8b      # default for ollama
  # Set your API keys in the environment (e.g., OPENAI_API_KEY, GEMINI_API_KEY)
```

## License

This software is released under a **Proprietary License**. Source code is closed-source. See [LICENSE](LICENSE) for details.
