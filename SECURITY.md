# Security policy — kekbull_governance (`2uNHeSLi…`)

Report vulnerabilities in the mainnet vote program
`2uNHeSLiNn6dLLtiGrpCd8UZKBfV36kap57eg9kV39Fj` here. Do not open a public
GitHub issue for an unfixed exploit.

This is a minimal SPL Governance 3.1.2 fork so Token-2022 TransferFeeConfig
mints can CastVote / FinalizeVote. Diff vs upstream is mint-validation plus
`declare_id`.

## Contact

- email: crypto.raistlin@gmail.com
- Telegram: https://t.me/kekbull

## Source

https://github.com/KEKBULL-ICHOR-DAO/kekbull-governance

On-chain `security.txt` is the Program Metadata `security` PDA, not an
ELF section. This file is the policy that PDA points at.
