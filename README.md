# ACA CLI

Command-line interface for Azure Container Apps.

## Installation

### Linux / macOS

```sh
curl -fsSL https://raw.githubusercontent.com/annaji-msft/aca/main/install.sh | sh
```

To install a specific version:

```sh
ACA_VERSION=v0.1.0-preview curl -fsSL https://raw.githubusercontent.com/annaji-msft/aca/main/install.sh | sh
```

### Windows (PowerShell)

```powershell
irm https://raw.githubusercontent.com/annaji-msft/aca/main/install.ps1 | iex
```

To install a specific version:

```powershell
& ([scriptblock]::Create((irm https://raw.githubusercontent.com/annaji-msft/aca/main/install.ps1))) -Version v0.1.0-preview
```

## Supported Platforms

| Platform | Architecture |
|----------|-------------|
| Linux    | x64, ARM64  |
| macOS    | ARM64       |
| Windows  | x64         |

