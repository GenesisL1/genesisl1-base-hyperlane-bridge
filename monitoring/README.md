# Monitoring

> See [../DISCLAIMER.md](../DISCLAIMER.md). Monitoring tooling here is a
> starting point and does not guarantee detection of every failure.

Basic scripts for keeping the bridge operator-alertable. Adapt them to
your alerting stack.

## Scripts

### `relayer-balance-check.sh`

Checks the relayer wallet balance on both chains against configurable
thresholds. Exits non-zero if any balance is below threshold, so it can
be wired to cron + any alerting tool (dead man's snitch, PagerDuty,
healthchecks.io, etc.).

Cron example:

```cron
*/10 * * * * /opt/hyperlane/monitoring/relayer-balance-check.sh >> /var/log/relayer-balance.log 2>&1
```

Environment variables:

- `RELAYER_ADDR` — wallet to check (default: canonical relayer)
- `BASE_MIN_WEI` — alert threshold on Base (default: 0.01 ETH)
- `GEN_MIN_WEI` — alert threshold on GenesisL1 (default: 50 L1)
- `BASE_RPC`, `GEN_RPC` — override RPC endpoints

### `collateral-mismatch-alert.sh`

Alerting version of [`../scripts/check-collateral.sh`](../scripts/check-collateral.sh):
compares wL1 locked in the GenesisL1 collateral router with synthetic wL1
supply on Base. A short mismatch is normal while a transfer is in flight,
so it only exits non-zero when the mismatch persists longer than
`GRACE_SEC`. It also reports which side is larger: synthetic supply
exceeding locked collateral is the dangerous case.

Uses only `curl` (no Foundry), so it runs on a bare cron host.

Exit codes: `0` balanced or within grace, `1` persistent mismatch,
`3` RPC failure.

Cron example:

```cron
*/5 * * * * /opt/hyperlane/monitoring/collateral-mismatch-alert.sh >> /var/log/collateral.log 2>&1
```

Environment variables:

- `GRACE_SEC` — how long a mismatch may last before alerting (default: 600)
- `STATE_FILE` — where the first-mismatch timestamp is kept
  (default: `/var/tmp/wl1-collateral-mismatch.since`)
- `GEN_RPC`, `BASE_RPC` — override RPC endpoints
- `WL1_TOKEN_GENESIS`, `GENESIS_ROUTER`, `WL1_TOKEN_BASE` — override
  contract addresses (defaults from [docs/contracts.md](../docs/contracts.md))

## Roadmap

Not yet included but useful to add:

- Prometheus exporter for validator signature lag
- Dashboard showing `Dispatched` vs `Delivered` message counts per direction
- Alert when the latest validator checkpoint is older than N minutes
