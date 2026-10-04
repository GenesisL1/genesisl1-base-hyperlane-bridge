# Running a Validator

> **Before running a validator, read [DISCLAIMER.md](../DISCLAIMER.md).**
> You are operating public infrastructure with real keys and real funds.

A validator observes one chain, signs checkpoints of dispatched messages,
and publishes signatures to a storage location where relayers can fetch
them.

## Prerequisites

- Linux server (4 GB RAM minimum, 20 GB disk)
- Docker and Docker Compose v2+
- A dedicated EVM private key (never reuse across chains or with other
  infrastructure)
- A small amount of native gas token on the chain being validated (for
  the one-time `announce` transaction)
- A place to publish checkpoint signatures — one of:
  - AWS S3 or GCS bucket (recommended for public validators)
  - Your own HTTPS server pointing at the local signatures directory

## 1. Clone the repo

```bash
git clone https://github.com/GenesisL1/genesisl1-base-hyperlane-bridge.git
cd genesisl1-base-hyperlane-bridge/validator
```

## 2. Generate (or import) a validator key

Validator keys must be unique per chain and per infrastructure role. Do
not reuse with your relayer or your personal wallet.

```bash
../scripts/generate-validator-key.sh
```

This prints a fresh private key and the corresponding address. Save both
securely. The address is what other ISM configs will reference. The key
goes in `.env`.

## 3. Configure

```bash
cp .env.example .env
```

Edit `.env`. Minimum variables to set:

```
HYP_VALIDATOR_KEY=0x<your-validator-private-key>
HYP_CHAINS_GENESISL1_SIGNER_KEY=0x<your-validator-private-key>
HYP_CHAINS_BASE_SIGNER_KEY=0x<your-validator-private-key>
```

For local testing only, you can leave the checkpoint URL default and use
the local filesystem. **Nobody else will be able to fetch your checkpoints
in that case**, so for a public validator this is not usable.

## 4. Choose which chain(s) to validate

The default compose file defines two services: `validator_genesisl1` and
`validator_base`. Start only the ones you want to run.

```bash
# validate GenesisL1 only
docker compose up -d validator_genesisl1

# validate Base only
docker compose up -d validator_base

# validate both
docker compose up -d
```

## 5. Check logs

```bash
docker compose logs -f validator_genesisl1
```

Expected output: periodic "signed checkpoint at index N" messages. If
you see repeated errors about RPC or block height, check your RPC
endpoints.

## 6. Announce the validator on-chain

First-time setup only. The agent writes an `announcement.json` into your
signatures directory once it starts. You then submit that announcement
to the target chain's `ValidatorAnnounce` contract.

```bash
export VALIDATOR_KEY=0x<key-paying-for-announce>
../scripts/announce-validator.sh genesisl1 ./signatures/genesisl1/announcement.json
```

Without announcement, your validator produces signatures but nobody can
find them. This is a one-time cost in native gas on the target chain.

## 7. Make checkpoints publicly reachable

Relayers need to fetch your signatures. Your checkpoint URL must serve
the contents of the local `signatures/<chain>/` directory over HTTPS.

Options:

- **AWS S3**: set `HYP_CHECKPOINTSYNCER_TYPE=s3` in the compose env and
  provide AWS credentials via `.env`. See commented section of
  `.env.example`.
- **Self-hosted**: any static HTTPS server (nginx, Caddy, Cloudflare
  Pages) pointed at the signatures directory works.

Verify the URL is reachable from an unrelated host:

```bash
curl -v https://your-bucket.example.com/genesisl1/latest_index.json
```

If that fails, relayers cannot use your validator.

## 8. Get added to the canonical ISM

Running a validator does not automatically include you in the ISM. The
route owner must deploy a new ISM that includes your validator address
and call `setInterchainSecurityModule(newIsm)` on the warp router.

See [../CONTRIBUTING.md](../CONTRIBUTING.md) for the process.

## Reference

Complete env var documentation is in `../validator/.env.example`. The
required variables are covered above.
