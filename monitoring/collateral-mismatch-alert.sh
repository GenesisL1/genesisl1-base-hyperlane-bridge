#!/usr/bin/env bash
# Alert when wL1 locked on GenesisL1 and synthetic wL1 supply on Base diverge.
#
# A short mismatch is normal while a transfer is in flight (~20-30 s), so
# this only alerts when the mismatch persists longer than GRACE_SEC.
# Intended to be run from cron; exits non-zero for alerting.
#
# Exit codes:
#   0  balanced, or mismatch still within the grace period
#   1  mismatch persisted longer than GRACE_SEC
#   3  could not read one of the RPCs

set -euo pipefail
shopt -s extglob

GEN_RPC="${GEN_RPC:-https://rpc.genesisl1.org}"
BASE_RPC="${BASE_RPC:-https://mainnet.base.org}"

WL1_TOKEN_GENESIS="${WL1_TOKEN_GENESIS:-0x59a153c0fD47C6c1F305Abdb8030A90Aa3001fe2}"
GENESIS_ROUTER="${GENESIS_ROUTER:-0x05Cd463228768Bec155CBe9180E95652490beCf6}"
WL1_TOKEN_BASE="${WL1_TOKEN_BASE:-0xE6522A891702Cd2E8CC2A5182638c9DA1DD44B22}"

GRACE_SEC="${GRACE_SEC:-600}"
STATE_FILE="${STATE_FILE:-/var/tmp/wl1-collateral-mismatch.since}"

# eth_call <rpc> <to> <data> -> 0x-prefixed hex result, or empty on failure
eth_call() {
  local rpc="$1" to="$2" data="$3"
  curl -s --max-time 15 -X POST -H "Content-Type: application/json" \
    --data "{\"jsonrpc\":\"2.0\",\"id\":1,\"method\":\"eth_call\",\"params\":[{\"to\":\"$to\",\"data\":\"$data\"},\"latest\"]}" \
    "$rpc" | sed -nE 's/.*"result":"(0x[0-9a-fA-F]+)".*/\1/p'
}

# Strip 0x, leading zeros and case so equal values compare equal as strings.
norm_hex() {
  local h="${1#0x}"
  h="${h,,}"
  h="${h##+(0)}"
  echo "${h:-0}"
}

# uint256 values exceed bash's 64-bit integers, so convert to a decimal
# string for display and comparison.
hex_to_dec() {
  local hex="${1#0x}" limbs=(0) i j d carry v out
  hex="${hex,,}"
  for (( i = 0; i < ${#hex}; i++ )); do
    d=$(( 16#${hex:i:1} ))
    carry=$d
    for (( j = 0; j < ${#limbs[@]}; j++ )); do
      v=$(( limbs[j] * 16 + carry ))
      limbs[j]=$(( v % 1000000000 ))
      carry=$(( v / 1000000000 ))
    done
    (( carry > 0 )) && limbs+=("$carry")
  done
  out="${limbs[-1]}"
  for (( j = ${#limbs[@]} - 2; j >= 0; j-- )); do
    out+=$(printf "%09d" "${limbs[j]}")
  done
  echo "$out"
}

# dec_lt A B -> success if decimal string A < decimal string B
dec_lt() {
  if (( ${#1} != ${#2} )); then
    (( ${#1} < ${#2} ))
  else
    [[ "$1" < "$2" ]]
  fi
}

# balanceOf(address): selector 0x70a08231 + address left-padded to 32 bytes
router_hex="${GENESIS_ROUTER#0x}"
BALANCE_OF_DATA="0x70a08231$(printf '%064s' "${router_hex,,}" | tr ' ' 0)"
TOTAL_SUPPLY_DATA="0x18160ddd"

LOCKED_HEX=$(eth_call "$GEN_RPC" "$WL1_TOKEN_GENESIS" "$BALANCE_OF_DATA" || true)
SUPPLY_HEX=$(eth_call "$BASE_RPC" "$WL1_TOKEN_BASE" "$TOTAL_SUPPLY_DATA" || true)

if [[ -z "$LOCKED_HEX" || -z "$SUPPLY_HEX" ]]; then
  echo "FAIL: could not read one of the RPCs"
  exit 3
fi

LOCKED=$(hex_to_dec "$(norm_hex "$LOCKED_HEX")")
SUPPLY=$(hex_to_dec "$(norm_hex "$SUPPLY_HEX")")
NOW=$(date +%s)

echo "Locked on GenesisL1: $LOCKED wei"
echo "Synthetic on Base:   $SUPPLY wei"

if [[ "$LOCKED" == "$SUPPLY" ]]; then
  echo "  OK: balanced"
  rm -f "$STATE_FILE"
  exit 0
fi

if dec_lt "$LOCKED" "$SUPPLY"; then
  echo "  Mismatch: synthetic supply EXCEEDS locked collateral"
else
  echo "  Mismatch: locked collateral exceeds synthetic supply"
fi

SINCE=""
[[ -f "$STATE_FILE" ]] && SINCE=$(<"$STATE_FILE")
if [[ ! "$SINCE" =~ ^[0-9]+$ ]]; then
  SINCE="$NOW"
  echo "$SINCE" > "$STATE_FILE"
fi
AGE=$(( NOW - SINCE ))

if (( AGE >= GRACE_SEC )); then
  echo "  ALERT: mismatch persisted for ${AGE}s (grace ${GRACE_SEC}s)"
  exit 1
fi

echo "  Within grace period (${AGE}s of ${GRACE_SEC}s), likely a transfer in flight"
exit 0
