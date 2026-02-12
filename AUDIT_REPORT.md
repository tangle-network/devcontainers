# Re-Audit Report: `fix/ci-agent-user-passwd` (post `0c6aa9e`)

## Commits Reviewed
1. `83c6b52` — fix(ci): align generated images to agent user and sha-pinned build contexts
2. `b72644d` — feat(infra): enhance dockerfiles with additional tools, pre-warming caches, and user permission fixes
3. `0c6aa9e` — chore: address review concerns

---

## Previously Reported Bugs — Status After Fix

### BUG 1: `universal.Dockerfile` — `su - project` / missing PATH/GOPATH

**FIXED.** Lines 25-26 now correctly read:

    su - agent -c 'export PATH=/usr/local/go/bin:/go/bin:$PATH GOPATH=/go && go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest'
    su - agent -c 'export PATH=/usr/local/go/bin:/go/bin:$PATH GOPATH=/go && go install golang.org/x/tools/gopls@latest'

Both the user (`agent`) and the PATH/GOPATH environment are restored.

---

### BUG 2: `--break-system-packages` removed from pip3 install (15 Dockerfiles)

**FIXED.** All 16 Dockerfiles now include `--break-system-packages` on every `pip3 install`:

| File | Status |
|---|---|
| clickhouse | `--break-system-packages` present |
| elasticsearch | `--break-system-packages` present |
| hyperliquid | `--break-system-packages` present |
| kafka | `--break-system-packages` present |
| kubernetes | `--break-system-packages` present |
| milvus | `--break-system-packages` present |
| minio | `--break-system-packages` present |
| pgvector | `--break-system-packages` present |
| pulumi | `--break-system-packages` present |
| qdrant | `--break-system-packages` present |
| redis | `--break-system-packages` present |
| starknet | `--break-system-packages` present |
| terraform | `--break-system-packages` present |
| ton | `--break-system-packages` present |
| universal | `--break-system-packages` present |
| weaviate | `--break-system-packages` present |

---

### BUG 3: `risc0.Dockerfile` — inverted command ordering

**FIXED.** The Dockerfile now matches the correct ordering from main:

    RUN cargo install cargo-risczero && \
        cargo risczero install || echo 'RISC Zero toolchain installed'

PATH also correctly includes `/root/.risc0/bin`.

---

### BUG 4: `tangle.Dockerfile` / `solana.Dockerfile` — `chmod -R a+w $CARGO_HOME` as agent

**FIXED.** Both files now switch to root before the chmod:

    USER root
    RUN chmod -R a+w $CARGO_HOME
    USER agent

The `generate_docker.js` was also fixed to emit this pattern for all cargo cache warming blocks.

---

### BUG 5: `langchain.Dockerfile` — `pip download --break-system-packages`

**FIXED.** The `pip download` command no longer includes the invalid flag:

    RUN pip download --dest /tmp/pip-warm openai anthropic tiktoken chromadb sentence-transformers && rm -rf /tmp/pip-warm

The `generate_docker.js` was also updated to not emit `--break-system-packages` for `pip download`.

---

### BUG 6: `kubernetes.Dockerfile` / `minio.Dockerfile` — hardcoded amd64

**FIXED.** Both files now use dynamic architecture detection:

    ARCH=$(uname -m) && \
    if [ "$ARCH" = "x86_64" ]; then ARCH="amd64"; elif [ "$ARCH" = "aarch64" ]; then ARCH="arm64"; fi && \
    ...

kubernetes: kubectl, kind, k9s, kustomize all use `${ARCH}`.
minio: both minio server and mc client use `${ARCH}`.

---

### `generate_docker.js` — `USER project` references

**FIXED.** All 6 occurrences of `USER project` changed to `USER agent` in both `generateInfraDockerfile()` and `generateCombinedDockerfile()`.

---

## All 6 Previously Reported Bugs Are Resolved

---

## Remaining Warnings (unchanged from original report)

These are not build-breaking but worth noting:

### WARNING 1: `DEBIAN_FRONTEND=noninteractive` regressions in `config.json`

Three `config.json` entries have `apt-get install` in `root_commands` without `DEBIAN_FRONTEND=noninteractive`, which was present on main:

- **clickhouse**: `apt-get update && apt-get install -y clickhouse-server clickhouse-client` — ClickHouse prompts for a default password during install
- **elasticsearch**: `apt-get update && apt-get install -y elasticsearch` — Elasticsearch may prompt during postinst
- **mongodb**: `apt-get update && apt-get install -y mongodb-org` — MongoDB may prompt during configuration

Main had `DEBIAN_FRONTEND=noninteractive` inline on all three. The `apt_packages` path in the generator correctly adds it, but these use `root_commands` where it must be manually included.

**Severity: Low-Medium.** Docker builds may not actually hang (no TTY), but some packages explicitly check and could fail. Safest to add it back.

**Fix**: Prepend `DEBIAN_FRONTEND=noninteractive` to the `apt-get install` in each `root_commands` entry.

---

### WARNING 2: MongoDB downgrade 8.0 to 7.0

Main uses `server-8.0` with `jammy` repo. Fix branch uses `server-7.0` with `noble` repo. This is a major version downgrade. Could be intentional (8.0 may not have a `noble` repo yet), but worth confirming.

---

### WARNING 3: Non-deterministic `git clone` without pinned refs

- `hyperliquid.Dockerfile`: `git clone --depth 1 https://github.com/hyperliquid-dex/node.git`
- `tempo.Dockerfile`: `git clone --depth 1 https://github.com/tempoxyz/tempo.git`

Both clone the default branch HEAD without pinning to a tag or commit. Builds are non-reproducible.

---

### WARNING 4: `qdrant.Dockerfile` — compiling from source

`cargo install qdrant` compiles the entire Qdrant database from source. This is extremely resource-intensive and may timeout or OOM in CI. The fallback downloads an `x86_64` binary only (no arm64 variant).

---

### WARNING 5: Tangle functional change

The tangle image was significantly reworked — `cargo-tangle` CLI was removed and replaced with `subxt-cli` + substrate dependencies (`sp-core`, `sp-runtime`, `frame-support`). This appears intentional but is a breaking change for users expecting `cargo-tangle`.

---

## Summary

| # | Original Bug | Status |
|---|---|---|
| 1 | `universal.Dockerfile` — `su - project` + missing PATH | **FIXED** |
| 2 | `--break-system-packages` removed from 15 Dockerfiles | **FIXED** |
| 3 | `risc0.Dockerfile` — inverted command ordering | **FIXED** |
| 4 | `tangle/solana` — `chmod` as agent user | **FIXED** |
| 5 | `langchain.Dockerfile` — invalid `pip download` flag | **FIXED** |
| 6 | `kubernetes/minio` — hardcoded amd64 | **FIXED** |
| — | `generate_docker.js` — `USER project` references | **FIXED** |

**The PR has addressed all 6 categories of build-breaking bugs.** The remaining items are warnings/improvements that are unlikely to block builds but would be good to address before merge.
