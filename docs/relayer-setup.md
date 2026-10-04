# Running a Relayer

> **Before running a relayer, read [DISCLAIMER.md](../DISCLAIMER.md).**
> Relayer wallets hold real funds on multiple chains and are a target.

A relayer reads validator signatures, constructs ISM metadata, and
submits `process()` calls on destination mailboxes. Anyone can run a
relayer — no canonical approval required.

## Prerequisites

- Linux server (2 GB RAM minimum, 10 GB disk)
- Docker and Docker Compose v2+
- A dedicated EVM private key for the relayer wallet
- **The relayer wallet must hold gas tokens on every destination chain**
  it relays to:
  - ETH on Base
  - L1 on GenesisL1

## 1. Clone and configure

```bash
git clone https://github.com/GenesisL1/genesisl1-base-hyperlane-bridge.git
cd genesisl1-base-hyperlane-bridge/relayer

cp .env.example .env
```

Edit `.env`:

```
HYP_DEFAULTSIGNER_KEY=0x<your-relayer-private-key>
```

## 2. Fund the relayer wallet

Derive the address from your private key and send gas funds. For
GenesisL1, transfer some L1. For Base, transfer some ETH.

Recommended starting balances:

- Base: 0.05 ETH
- GenesisL1: 100 L1

Monitor and refill. See
[../monitoring/relayer-balance-check.sh](../monitoring/relayer-balance-check.sh).

## 3. Start the relayer

```bash
docker compose up -d
docker compose logs -f relayer
```

## 4. Expected behavior

A healthy relayer logs show:

```
INFO  checking chain for new dispatches
INFO  found N pending messages
INFO  submitting process() tx
INFO  tx finalized, message delivered
```

Common error messages are covered in
[troubleshooting.md](troubleshooting.md).

## 5. Gas enforcement setting

This route has no IGP on GenesisL1. Users do not pay destination gas.
The relayer pays it.

The default configuration sets:

```
HYP_GASPAYMENTENFORCEMENT=[{"type":"none"}]
```

If you run a private relayer and don't want to subsidize anyone, you can
set this to a stricter policy — but on this route, there is no gas
payment to verify against, so messages simply won't deliver. Leave it as
`none` for normal operation.

## 6. EIP-1559 overrides on Base

The default config includes:

```
HYP_CHAINS_BASE_TRANSACTIONOVERRIDES_MAXFEEPERGAS=2000000000
HYP_CHAINS_BASE_TRANSACTIONOVERRIDES_MAXPRIORITYFEEPERGAS=100000000
HYP_CHAINS_BASE_TRANSACTIONOVERRIDES_GASPRICECAP=5000000000
```

These work with current Base gas conditions. If Base gas rises
sustainably, you may need to raise them. Symptom of values being too
low: transactions sit in the mempool indefinitely and retries fail with
"replacement underpriced".

## 7. GenesisL1 gas quirk

GenesisL1's `eth_estimateGas` is known to return incorrect values. The
relayer handles this internally with its own pricing, but external
scripts that interact with GenesisL1 should always pass explicit
`gasLimit` and `gasPrice`. See [troubleshooting.md](troubleshooting.md).
