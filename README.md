# Hyperlane: GenesisL1 ↔ Base Bridge

Self-hostable validator and relayer configurations for the **wL1 warp route**
connecting **GenesisL1** (domain 29) and **Base** (domain 8453) via
[Hyperlane](https://hyperlane.xyz).

This repository contains everything needed to:

- Run a **validator** observing either chain and signing checkpoints.
- Run a **relayer** that delivers messages across the route.
- Verify bridge state and monitor operational health.

> ## ⚠️ READ THIS FIRST — [DISCLAIMER.md](DISCLAIMER.md)
>
> **This is open-source, decentralized, _exceptionally experimental_ software
> provided "AS-IS" and "AS-AVAILABLE" with NO WARRANTY and NO LIABILITY of any
> kind.** It is a community-run experiment, not a product or a service. There
> is no support, no SLA, no backstop, and no one obligated to make you whole.
> It can break or stop permanently at any time, and anything you put through it
> can be lost forever. **Use it only with funds, hardware, and time you can
> afford to lose entirely.**
>
> **Validators and relayers:** you run **neutral, non-custodial, automated
> infrastructure**. You do not take custody of user funds, you are not a
> counterparty to any user, and the disclaimer is written to protect you from
> liability for what users do. See
> **[§3 — Protection for Validators and Relayers](DISCLAIMER.md#3-protection-for-validators-and-relayers)**.
>
> Full terms: **[DISCLAIMER.md](DISCLAIMER.md)** — read before proceeding.


## Quick Links

- [Disclaimer](DISCLAIMER.md) ← **read before running anything**
- [Architecture overview](docs/architecture.md)
- [Deployed contracts](docs/contracts.md)
- [Validator setup guide](docs/validator-setup.md)
- [Relayer setup guide](docs/relayer-setup.md)
- [Troubleshooting](docs/troubleshooting.md)
- [Contributing](CONTRIBUTING.md)

## Network Overview

| Chain     | Domain | Chain ID | RPC                          | Explorer                       |
| --------- | ------ | -------- | ---------------------------- | ------------------------------ |
| GenesisL1 | 29     | 29       | https://rpc.genesisl1.org    | https://explorer.genesisl1.org |
| Base      | 8453   | 8453     | https://mainnet.base.org     | https://basescan.org           |

## The Warp Route

A Hyperlane collateral/synthetic warp route for the native L1 coin, wrapped
to `wL1` (ERC-20, 18 decimals) for cross-chain transfer.

- **Collateral side** (GenesisL1): users wrap native L1 → wL1, then
  `transferRemote(8453, recipient, amount)` locks wL1 in the collateral
  router.
- **Synthetic side** (Base): relayer delivers the message, synthetic wL1 is
  minted on Base to the recipient.
- Reverse direction burns on Base and unlocks on GenesisL1.

Delivery latency: ~20–30 seconds end-to-end in normal conditions.

## Quick Start

### Run a validator

```
sudo N=1 MINIO_KEY=val1 MINIO_SECRET='...' PRIVATE_KEY=0x... \
     BASE_RPCS='https://rpc.ankr.com/base/<YOUR_ANKR_KEY>,https://base-rpc.publicnode.com' \
     bash 1-validator.sh
```

```bash
git clone https://github.com/GenesisL1/genesisl1-base-hyperlane-bridge.git
cd genesisl1-base-hyperlane-bridge/validator

cp .env.example .env
# edit .env, fill in HYP_VALIDATOR_KEY

docker compose up -d validator_genesisl1
```

See [docs/validator-setup.md](docs/validator-setup.md) for the full guide.

### Run a relayer

```bash
cd genesisl1-base-hyperlane-bridge/relayer

cp .env.example .env
# edit .env, fill in HYP_DEFAULTSIGNER_KEY

docker compose up -d
```

See [docs/relayer-setup.md](docs/relayer-setup.md) for the full guide.

## Status

| Component                          | Status                                     |
| ---------------------------------- | ------------------------------------------ |
| GenesisL1 → Base message delivery  | ✅ live                                    |
| Base → GenesisL1 message delivery  | ✅ live                                    |
| IGP on GenesisL1                   | ❌ not deployed (relayer-subsidized)       |
| IGP on Base                        | ⚠️  not wired into this route              |
| Validator diversity                | 🟡 threshold 1/1 — seeking more operators  |

## Contributing

Additional validators, relayer operators, and contributors are welcome. See
[CONTRIBUTING.md](CONTRIBUTING.md).

## License

[MIT](LICENSE) — with the explicit warranty and liability carve-outs in
[DISCLAIMER.md](DISCLAIMER.md). The software is provided as-is.
