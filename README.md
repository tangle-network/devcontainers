# Tangle Blueprint Agent Containers

A streamlined Docker image architecture for blockchain and infrastructure development environments, featuring automatic deduplication and intelligent layer caching.

## Quick Start

```bash
# Generate Dockerfiles
node generate_docker.js ethereum solana

# Build images
./build.sh base                    # Base system
./build.sh intermediate rust       # Rust layer (for Rust projects)
./build.sh infra ethereum          # Node.js project (direct from base)
./build.sh infra solana            # Rust project (via rust layer)

# Verify
node generate_docker.test.js
```

## Architecture

A two-layer architecture that maximizes efficiency by including Node.js and Python in the base system:

```
┌──────────────────────────────────────────────┐
│  Infrastructure Layer                        │
│  Project-specific SDKs and packages          │
├──────────────────────────────────────────────┤
│  Rust Layer (optional, Rust projects only)  │
│  Rust toolchain via rustup                   │
├──────────────────────────────────────────────┤
│  Base System                                 │
│  Ubuntu 24.04 + Node.js 22 + Python 3       │
└──────────────────────────────────────────────┘
```

### Base System Layer

**Image:** `base-system:latest`  
**Includes:** Ubuntu 24.04, Node.js 22, Python 3, build tools (gcc, cmake, make)  
**Used by:** All projects

The base system contains everything needed for Node.js and Python development, so most projects build directly from it.

### Rust Layer (Optional)

**Image:** `rust:latest`  
**Adds:** Rust toolchain (rustc, cargo, rustup)  
**Used by:** Rust projects only (solana, sui, aptos, risc0, tangle, etc.)

Only Rust projects need this intermediate layer. Node.js and Python projects skip it entirely.

### Infrastructure Layer

**Images:** `ethereum:latest`, `solana:latest`, `coinbase:latest`, etc.  
**Contains:** Project-specific packages (npm or cargo)

Examples:
- `ethereum`: `FROM base-system` + ethers, viem
- `solana`: `FROM rust` + solana-sdk, anchor-lang  
- `mongodb`: `FROM base-system` + mongodb driver

## Available Projects

| Category | Projects | Base Layer |
|----------|----------|------------|
| **Blockchain (EVM)** | ethereum, polygon, zksync, injective | base-system |
| **Blockchain (Rust)** | solana, sui, aptos, tangle, stylus | rust |
| **ZK Proofs** | risc0, succinct, brevis | rust |
| **APIs** | coinbase | base-system |
| **Databases** | mongodb, postgresql, convex | base-system |
| **Infrastructure** | rindexer, reth | rust |

## Usage

### Generate Dockerfiles

```bash
# Single project
node generate_docker.js ethereum

# Multiple projects
node generate_docker.js ethereum solana coinbase

# Combined project (must share same base)
node generate_docker.js ethereum_polygon_zksync
```

### Automatic Deduplication

Projects are automatically sorted alphabetically to prevent duplicates:

```bash
# These all generate the same file: ethereum_polygon_zksync.Dockerfile
node generate_docker.js ethereum_polygon_zksync
node generate_docker.js zksync_polygon_ethereum
node generate_docker.js polygon_ethereum_zksync
```

### Build Images

```bash
# Build all
./build.sh all

# Build selectively
./build.sh base                   # Base system (required first)
./build.sh intermediate rust      # Rust layer only
./build.sh infra ethereum         # Specific project
```

## Configuration

Projects are defined in `config.json`:

```json
{
  "intermediate_templates": {
    "rust": "FROM base-system:latest\n..."
  },
  "projects": {
    "ethereum": {
      "base": "base-system",
      "packages": { "npm": ["ethers", "viem"] }
    },
    "solana": {
      "base": "rust",
      "packages": { "cargo": ["solana-sdk"] }
    }
  }
}
```

**Key Points:**
- Node.js/Python projects use `"base": "base-system"`
- Rust projects use `"base": "rust"`
- Packages are installed globally (npm) or via cargo

## Combining Projects

Projects can be combined if they share the same base layer:

**Valid:**
```bash
# All use base-system
node generate_docker.js ethereum_polygon_zksync_mongodb

# All use rust
node generate_docker.js solana_sui_aptos_risc0
```

**Invalid:**
```bash
# Different bases (base-system vs rust)
node generate_docker.js ethereum_solana
# Error: Cannot combine projects with different base images
```

Solution: Generate separately:
```bash
node generate_docker.js ethereum solana
```

## Adding New Projects

1. **Edit `config.json`:**

```json
{
  "projects": {
    "myproject": {
      "base": "base-system",
      "packages": { "npm": ["my-package"] }
    }
  }
}
```

2. **Generate and build:**

```bash
node generate_docker.js myproject
./build.sh infra myproject
```

3. **For Rust projects, use `"base": "rust"`** instead of `"base-system"`

## Testing

Run the comprehensive test suite:

```bash
node generate_docker.test.js
```

Tests verify:
- Alphabetical sorting and deduplication
- Consistent file generation across different orderings
- Label correctness
- Multiple project combinations

## File Structure

```
.
├── base/
│   └── base-system.Dockerfile        # Base system with Node.js + Python
├── intermediate/
│   └── rust.Dockerfile               # Rust toolchain (optional)
├── infra/
│   ├── ethereum.Dockerfile           # FROM base-system
│   ├── solana.Dockerfile             # FROM rust
│   └── ...                           # Other projects
├── config.json                       # Project definitions
├── generate_docker.js                # Dockerfile generator
├── generate_docker.test.js           # Test suite
└── build.sh                          # Build script
```

## Design Benefits

**Simplified Architecture**
- Most projects (Node.js/Python) build directly from base-system
- Only Rust requires an intermediate layer
- Clear separation of concerns

**Efficiency**
- Maximizes Docker layer caching
- Prevents redundant intermediate layers
- Automatic deduplication via alphabetical sorting

**Developer Experience**
- Single command for complex multi-project images
- Automatic validation and error checking
- Comprehensive test coverage

**Layer Reuse**
```
base-system (Node.js + Python)
    ├── ethereum
    ├── polygon
    ├── coinbase
    ├── mongodb
    └── rust
        ├── solana
        ├── sui
        └── risc0
```

## Best Practices

1. **Build order:** Always build `base` before `intermediate` or `infra` layers
2. **Combined images:** Use for projects commonly deployed together
3. **Minimal packages:** Only install required dependencies
4. **Test changes:** Run test suite after modifying `config.json`
5. **Alphabetical order:** Let the system handle it automatically

## Troubleshooting

**"Cannot combine projects with different base images"**
- Projects use different base layers (base-system vs rust)
- Generate them separately instead of combining

**"Unknown project"**
- Project not defined in `config.json`
- Check spelling or add the project definition

**"No such image" during build**
- Parent image hasn't been built yet
- Build in order: base → intermediate → infra

**Tests fail after config changes**
- Regenerate Dockerfiles: `node generate_docker.js project-name`
- Rebuild images: `./build.sh infra project-name`

## Advanced

### Custom Intermediate Layers

Add new language runtimes to `config.json`:

```json
{
  "intermediate_templates": {
    "golang": "FROM base-system:latest\n\nRUN apt-get install -y golang\n\nLABEL description=\"Go layer\"\n"
  }
}
```

**Note:** Only add intermediate layers for runtimes NOT in base-system.

### Environment Variables

- Base system: npm/pnpm cache configuration
- Rust layer: `CARGO_HOME`, `RUSTUP_HOME`, `PATH`

### User Configuration

All images run as `project` user (UID 1000) with sudo access for security.

## Image Naming

- **Base:** `base-system:latest`
- **Intermediate:** `rust:latest`
- **Infrastructure:** `{project}:latest`
- **Combined:** `{project1}_{project2}:latest` (alphabetically sorted)

## License

MIT
