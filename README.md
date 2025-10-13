# Tangle Blueprint Agent Containers

Docker images for tangle agent with official CLI tools and SDKs automatically installed from each project's documentation.

## Quick Start

```bash
# Generate Dockerfiles from config
node generate_docker.js solana ethereum sui

# Build all dependencies and images
./build.sh all

# Or build selectively
./build.sh base                # Base system (required first)
./build.sh intermediate rust   # Rust toolchain (for Rust projects)
./build.sh infra solana        # Solana with official CLI tools
./build.sh infra ethereum      # Ethereum with ethers/viem
```

**Built images include:**
- **Solana**: Official installer (Solana CLI + Anchor + NVM)
- **Sui**: Built from MystenLabs source
- **Aptos**: Built from Aptos Labs source
- **RISC Zero**: zkVM toolchain via cargo-risczero
- **Succinct SP1**: Official sp1up installer
- All others with their respective official tools

## Architecture

```
┌─────────────────────────────────────────────┐
│  Infrastructure Layer                       │
│  Official CLIs, SDKs, and toolchains        │
├─────────────────────────────────────────────┤
│  Rust Layer (optional)                      │
│  rustc, cargo, rustup                       │
├─────────────────────────────────────────────┤
│  Base System                                │
│  Ubuntu 24.04 + Node.js 22 + Python 3      │
└─────────────────────────────────────────────┘
```

**Base System** (`base-system:latest`)  
Ubuntu 24.04 with Node.js 22, Python 3, and build tools. Used by all projects.

**Rust Layer** (`rust:latest`)  
Adds Rust toolchain for blockchain projects. Optional - only used when needed.

**Infrastructure Layer** (`{project}:latest`)  
Project-specific installations using official methods from their documentation.

## Available Projects (18 Total)

| Category | Projects | Official Tools Installed |
|----------|----------|--------------------------|
| **Blockchains** | solana, sui, aptos, ethereum, polygon, zksync, injective, tangle, stylus | CLIs, SDKs, toolchains |
| **ZK Proofs** | risc0, succinct, brevis | zkVM toolchains |
| **Infrastructure** | reth, rindexer | Ethereum client, indexer |
| **APIs & DBs** | coinbase, mongodb, postgresql, convex | SDK packages |

## Usage

### Generate Dockerfiles

```bash
# Single or multiple projects
node generate_docker.js ethereum
node generate_docker.js ethereum solana coinbase

# Combined image (must share same base layer)
node generate_docker.js ethereum_polygon_zksync
```

**Note:** Combined projects are automatically sorted alphabetically.

### Build Images

```bash
# Build everything (recommended)
./build.sh all

# Build selectively
./build.sh base                   # Ubuntu + Node.js + Python (required first)
./build.sh intermediate rust      # Adds Rust (required for Rust projects)
./build.sh infra solana          # Project with official tools
```

**Build order matters:** `base` → `intermediate` (if needed) → `infra`

## Configuration

All projects are defined in `config.json` with official installation methods:

### Simple Package Installation

```json
{
  "projects": {
    "ethereum": {
      "base": "base-system",
      "packages": {
        "npm": ["ethers", "viem", "@wagmi/core"]
      }
    },
    "stylus": {
      "base": "rust",
      "packages": {
        "cargo": ["cargo-stylus"]
      }
    }
  }
}
```

### Custom Installation

For projects requiring official installers or build-from-source:

```json
{
  "projects": {
    "solana": {
      "base": "rust",
      "packages": { "cargo": [] },
      "custom_install": {
        "env": {
          "SOLANA_HOME": "/root/.local/share/solana",
          "PATH": "/root/.local/share/solana/install/active_release/bin:$PATH"
        },
        "apt_packages": ["libudev-dev"],
        "root_commands": [
          "curl --proto '=https' --tlsv1.2 -sSfL https://solana-install.solana.workers.dev | bash",
          "/root/.local/share/solana/install/active_release/bin/solana --version"
        ]
      }
    }
  }
}
```

**Options:**
- `env`: Environment variables to set
- `apt_packages`: System dependencies to install
- `root_commands`: Commands run as root user
- `commands`: Commands run as project user

This ensures all installations match official documentation exactly.

## Adding New Projects

1. Add to `config.json`:

```json
{
  "projects": {
    "myproject": {
      "base": "base-system",  // or "rust" for Rust projects
      "packages": { "npm": ["my-package"] }
    }
  }
}
```

2. Generate and build:

```bash
node generate_docker.js myproject
./build.sh infra myproject
```

For official installers, use `custom_install` (see Configuration section above).

## Testing

```bash
# Test Dockerfile generation
node generate_docker.test.js

# Validate package names
node validate.js

# Full validation with builds
node validate.js --full
```

## File Structure

```
base/
  base-system.Dockerfile       # Ubuntu + Node.js + Python
intermediate/
  rust.Dockerfile              # Rust toolchain
infra/
  ethereum.Dockerfile          # Generated project images
  solana.Dockerfile
  ...
config.json                    # Project definitions
generate_docker.js             # Dockerfile generator
build.sh                       # Build script
```
