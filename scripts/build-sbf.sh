#!/usr/bin/env bash
# Build kekbull_governance.so (minimal GovER5 3.1.2 fork).
# Uses platform-tools v1.53 (Cargo 1.89) so edition2024 transitive crates parse.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
./scripts/check-upstream-diff.sh
OUT="${CARGO_TARGET_DIR:-$ROOT/target}"
export CARGO_TARGET_DIR="$OUT"
cargo build-sbf --tools-version v1.53 --manifest-path program/Cargo.toml
echo "artifact: $OUT/deploy/kekbull_governance.so"
