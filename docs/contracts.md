# Deployed Contracts

> See [DISCLAIMER.md](../DISCLAIMER.md). These addresses are provided for
> reference and verification. **Always confirm addresses on-chain and in
> block explorers before using them.** Do not trust addresses copied from
> unofficial sources.

All addresses are EIP-55 checksummed.

## GenesisL1 (domain 29)

### Core

| Contract                               | Address                                      |
| -------------------------------------- | -------------------------------------------- |
| Mailbox                                | `0xE6522A891702Cd2E8CC2A5182638c9DA1DD44B22` |
| ValidatorAnnounce                      | `0x4AEcDf823ECe5808bE25daB0987152eB87E4BC52` |
| MerkleTreeHook                         | `0x8516B39Bca0f12f82B79065E633B8301eA5F0480` |
| StaticMerkleRootMultisigIsmFactory     | `0xE42eE416739D6beda0150F6951dF293AaB1ed27A` |
| StaticMessageIdMultisigIsmFactory      | `0x64E8De806F12a8dB8c04906838c87346D869bDa4` |
| ProxyAdmin                             | `0x8F03945D995B34F737C842F7eD0511433e8E60ce` |

No IGP deployed on GenesisL1 (by design — relayer-subsidized model).

### Warp route (wL1 collateral side)

| Contract                         | Address                                      |
| -------------------------------- | -------------------------------------------- |
| wL1 token (WETH9-style)          | `0x59a153c0fD47C6c1F305Abdb8030A90Aa3001fe2` |
| HypERC20Collateral router        | `0x05Cd463228768Bec155CBe9180E95652490beCf6` |
| ISM (validates msgs from Base)   | `0x5aD803d8635eE8a065938d3F36A85baecF517712` |

## Base (domain 8453)

### Core (Hyperlane canonical)

| Contract                               | Address                                      |
| -------------------------------------- | -------------------------------------------- |
| Mailbox                                | `0xeA87ae93Fa0019a82A727bfd3eBd1cFCa8f64f1D` |
| ValidatorAnnounce                      | `0x182E8d7c5F1B06201b102123FC7dF0EaeB445a7B` |
| MerkleTreeHook                         | `0x19dc38aeae620380430C200a6E990D5Af5480117` |
| StaticMerkleRootMultisigIsmFactory     | `0x8b83fefd896fAa52057798f6426E9f0B080FCCcE` |
| InterchainGasPaymaster                 | `0xc3F23848Ed2e04C0c6d41bd7804fa8f89F940B94` |

### Warp route (wL1 synthetic side)

| Contract                             | Address                                      |
| ------------------------------------ | -------------------------------------------- |
| wL1 synthetic + router (same addr)   | `0xE6522A891702Cd2E8CC2A5182638c9DA1DD44B22` |
| ISM (validates msgs from GenesisL1)  | `0xab41B4A43f10fBdd10381fBA2BB8A95A59938f7C` |

## Canonical validators

| Signs for | Validator address                            |
| --------- | -------------------------------------------- |
| GenesisL1 | `0x7F35C6adF5254908DF6604Ee664B8e1575213B80` |
| Base      | `0x249f11Ab83EE30914aDe60F47f53e854c3737524` |

## Canonical relayer

The wallet used by the operator of this route, made public for
transparency. Anyone can verify balance and transaction history:

```
0x27e4c47c4665887597ac952c0fe6ba80d096c1e2
```

- Base: https://basescan.org/address/0x27e4c47c4665887597ac952c0fe6ba80d096c1e2
- GenesisL1: https://explorer.genesisl1.org/address/0x27e4c47c4665887597ac952c0fe6ba80d096c1e2

Anyone may run their own relayer with a different wallet; the canonical
relayer is not privileged — it simply operates the default one.
