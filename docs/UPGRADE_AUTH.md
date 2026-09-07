# kekbull_governance upgrade authority

Upgrade authority stays with the creator wallet
`5E6eeUqF2UunqwGDavfCgh28smQe88JSN7MXGvCdh4Zd` until an explicit
`SetRealmAuthority` / `SetChecked` handoff to Governance
`H9hwaXvV5bXGrVRtrbd9n8PUmheAGeA7dDmvmwC45WnC`.

Day 90 after community voting opens is **stop and re-decide**, not a forced
handoff. If the activation bar has not been judged to hold, authority stays
where it is.

After handoff, program upgrades require a passed proposal and Execute. A bad
self-upgrade can freeze CastVote / FinalizeVote / Execute. That brick risk is
accepted and disclosed. There is no emergency withdraw outside governance.

Until handoff, live upgrade authority must be a durable key (survives reboot),
never tmpfs, never this git tree.

`app.realms.today` cannot host this DAO: it speaks GovER5 only. Holders use
[dao.kekbull.com](https://dao.kekbull.com) or any client that speaks program
`2uNHeSLiNn6dLLtiGrpCd8UZKBfV36kap57eg9kV39Fj`.
