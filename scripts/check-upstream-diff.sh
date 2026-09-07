#!/usr/bin/env bash
# Fail if the vendored program tree drifts beyond the allowlisted fork changes.
#
# Allowed relative to upstream/program:
#   - src/tools/spl_token.rs  (mint-validation: PodStateWithExtensions path)
# Everything else under program/src must be byte-identical to upstream.
#
# upstream/program/src is an immutable baseline. Its tree hash is pinned in
# scripts/upstream-src.sha256 - do not "fix" upstream to silence drift; update
# the pin only when intentionally re-vendoring a new upstream snapshot.
#
# Workspace Cargo.toml / package rename / build glue outside program/src are
# outside this check (not upstream program source).

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
UPSTREAM="$ROOT/upstream/program"
FORK="$ROOT/program"
UPSTREAM_PIN="$ROOT/scripts/upstream-src.sha256"

if [[ ! -d "$UPSTREAM/src" || ! -d "$FORK/src" ]]; then
  echo "check-upstream-diff: missing upstream/program/src or program/src" >&2
  exit 1
fi

hash_src_tree() {
  local dir="$1"
  (
    cd "$dir"
    find src -type f -print0 | sort -z | xargs -0 sha256sum
  ) | sha256sum | awk '{print $1}'
}

if [[ ! -f "$UPSTREAM_PIN" ]]; then
  echo "check-upstream-diff: missing upstream pin $UPSTREAM_PIN" >&2
  exit 1
fi
EXPECTED_UPSTREAM="$(tr -d '[:space:]' <"$UPSTREAM_PIN")"
ACTUAL_UPSTREAM="$(hash_src_tree "$UPSTREAM")"
if [[ "$ACTUAL_UPSTREAM" != "$EXPECTED_UPSTREAM" ]]; then
  echo "check-upstream-diff: FAIL - upstream/program/src was mutated" >&2
  echo "  pinned:  $EXPECTED_UPSTREAM" >&2
  echo "  actual:  $ACTUAL_UPSTREAM" >&2
  echo "  Re-vendor deliberately, then rewrite scripts/upstream-src.sha256." >&2
  exit 1
fi

ALLOWLIST=(
  "src/tools/spl_token.rs"
)

mapfile -t changed < <(
  diff -rq "$UPSTREAM/src" "$FORK/src" 2>/dev/null \
    | sed -n 's|^Files .*/upstream/program/\(.*\) and .*/program/\(.*\) differ$|\1|p' \
    || true
)

# Also catch Only-in differences as hard failures.
mapfile -t only_in < <(
  diff -rq "$UPSTREAM/src" "$FORK/src" 2>/dev/null \
    | sed -n 's/^Only in //p' \
    || true
)

fail=0
for path in "${only_in[@]:-}"; do
  if [[ -n "$path" ]]; then
    echo "check-upstream-diff: unexpected Only-in entry: $path" >&2
    fail=1
  fi
done

for path in "${changed[@]:-}"; do
  [[ -z "$path" ]] && continue
  allowed=0
  for a in "${ALLOWLIST[@]}"; do
    if [[ "$path" == "$a" ]]; then
      allowed=1
      break
    fi
  done
  if [[ "$allowed" -ne 1 ]]; then
    echo "check-upstream-diff: disallowed drift: $path" >&2
    fail=1
  else
    echo "check-upstream-diff: allowlisted change: $path"
  fi
done

if [[ "$fail" -ne 0 ]]; then
  echo "check-upstream-diff: FAIL - program/src drift beyond mint-validation allowlist" >&2
  exit 1
fi

# Require the mint-validation file actually differs (fork is intentional).
if diff -q "$UPSTREAM/src/tools/spl_token.rs" "$FORK/src/tools/spl_token.rs" >/dev/null; then
  echo "check-upstream-diff: FAIL - spl_token.rs is identical to upstream; fork mint fix missing" >&2
  exit 1
fi

# Require PodMint unpack inside the function body (not a comment-only sentinel).
# Strip // line comments and block-comment lines, then require a code call.
fn_body="$(
  awk '
    /fn assert_is_valid_spl_token_mint/ { in_fn=1 }
    in_fn {
      line=$0
      sub(/\/\/.*/, "", line)
      if (line ~ /\/\*/) { gsub(/\/\*.*\*\//, "", line) }
      print line
    }
    in_fn && /^}/ { exit }
  ' "$FORK/src/tools/spl_token.rs"
)"
if ! printf '%s\n' "$fn_body" | grep -q 'PodStateWithExtensions::<PodMint>::unpack'; then
  echo "check-upstream-diff: FAIL - PodMint unpack missing from assert_is_valid_spl_token_mint body" >&2
  exit 1
fi
if printf '%s\n' "$fn_body" | grep -q 'PodStateWithExtensions::<PodMint>::unpack' \
  && ! printf '%s\n' "$fn_body" | grep -E 'PodStateWithExtensions::<PodMint>::unpack\s*\(' >/dev/null; then
  echo "check-upstream-diff: FAIL - PodMint unpack appears but is not a call" >&2
  exit 1
fi

echo "check-upstream-diff: OK (upstream pin + allowlist-only drift + PodMint unpack in fn body)"
