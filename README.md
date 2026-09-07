# kekbull_governance

Minimal fork of SPL Governance 3.1.2 so CastVote and FinalizeVote work on Token-2022 mints with TransferFeeConfig (ICHOR). Stock GovER5 rejects those mints with custom error 548.

## Mainnet identity

| | |
|---|---|
| Program | `2uNHeSLiNn6dLLtiGrpCd8UZKBfV36kap57eg9kV39Fj` |
| Realm | `EJQ83ay57EH84wmqBk8r1dsqN7PSVmP83mY1DArq7ft9` (KEKBULL DAO) |
| Governance | `H9hwaXvV5bXGrVRtrbd9n8PUmheAGeA7dDmvmwC45WnC` |
| Native treasury | `Dn2cjgXaHLju8Gc5fRpvHX3AzeKAi3JwSjusPCoAYWGJ` |

Program id is the BPF Upgradeable deploy pubkey. There is no `declare_id!` in upstream 3.1.2; PDAs use the runtime program id.

## Hard rule

Diff vs `upstream/program/src` may only touch `src/tools/spl_token.rs`. CI: `scripts/check-upstream-diff.sh`.

## Build

```bash
./scripts/check-upstream-diff.sh
./scripts/build-sbf.sh
# artifact: $CARGO_TARGET_DIR/deploy/kekbull_governance.so
```

Dump the live program and compare hashes to verify this tree.

## Upgrade authority

Creator-held until an explicit realm-authority handoff to the Governance PDA. Day 90 after voting opens is stop-and-re-decide, not a forced transfer. Brick risk after handoff is accepted. See `docs/UPGRADE_AUTH.md`.

This repo does not ship deploy scripts or key material.
