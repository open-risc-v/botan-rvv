#!/usr/bin/env bash
# 真实包用例：botan SHA-256 与 CTR(AES-256)。
set -euo pipefail
: "${STAGE:=run}" "${SIDE:=A}" "${BIN:=build/native}" "${DATA:=build/ab-data}" "${OUT:=build/ab-data/out}"
mkdir -p "$DATA" "$OUT"
case "$STAGE" in
  gen) : > "$DATA/botan-input.txt" ;;
  run) "$BIN/botan_harness" "$OUT/botan.bin" > "$OUT/hash.txt" ;;
  *) echo "unknown STAGE=$STAGE" >&2; exit 2 ;;
esac
