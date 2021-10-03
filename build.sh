#!/bin/sh
set -e
clang \
  --target=wasm32 \
  --no-standard-libraries \
  -fvisibility=hidden \
  -O0 \
  -Wl,--no-entry \
  -Wl,--no-gc-sections \
  -Wl,--export-all \
  -Wl,--export-dynamic \
  -Wl,--import-memory \
  -Wl,-allow-undefined-file wasm.syms \
  -o coro.wasm \
  coro.ll \
  coro.c

if command -v wasm2wat >/dev/null; then
  wasm2wat coro.wasm -o coro.wast
fi
