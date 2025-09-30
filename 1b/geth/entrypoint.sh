#!/bin/bash
set -e

echo "Starting Geth EVM node..."

# Initialize genesis if needed
if [ ! -d "/root/.ethereum/geth" ]; then
  echo "Initializing Geth with dev mode..."
fi

# Start Geth with dev mode and Shanghai support
exec geth \
  --dev \
  --dev.period 1 \
  --datadir /root/.ethereum \
  --http \
  --http.addr 0.0.0.0 \
  --http.port 8545 \
  --http.corsdomain "*" \
  --http.vhosts "*" \
  --http.api "eth,net,web3,personal,miner,admin,debug" \
  --ws \
  --ws.addr 0.0.0.0 \
  --ws.port 8546 \
  --ws.api "eth,net,web3,personal,miner,admin,debug" \
  --ws.origins "*" \
  --allow-insecure-unlock \
  --mine \
  --networkid 1337 \
  --nodiscover \
  --verbosity 3 \
  --miner.gaslimit 8000000 \
  --override.shanghai 0
