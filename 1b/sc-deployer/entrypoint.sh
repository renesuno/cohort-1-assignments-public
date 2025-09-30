#!/bin/sh

set -e

echo "🚀 Starting smart contract deployment..."

# Wait for geth-init to complete prefunding
echo "⏳ Waiting for geth-init to complete prefunding..."
until [ -f "/shared/geth-init-complete" ]; do
  echo "Waiting for geth-init-complete file..."
  sleep 1
done
echo "✅ Prefunding completed, proceeding with deployment..."

# Clean up and clone repository fresh
echo "🧹 Cleaning up previous repository..."
rm -rf /workspace/cohort-1-assignments-public

cd /workspace

echo "📥 Using local assignment 1A..."
# Use mounted volume directly (already built)
cd /assignment1a

# Disable git discovery error
export GIT_DISCOVERY_ACROSS_FILESYSTEM=1

#  Deploy the contracts
echo "🚀 Deploying MiniAMM contracts..."
forge script script/MiniAMM.s.sol:MiniAMMScript \
    --rpc-url http://geth:8545 \
    --private-key be44593f36ac74d23ed0e80569b672ac08fa963ede14b63a967d92739b0c8659 \
    --broadcast \
    --skip-simulation

echo "✅ Deployment completed!"
echo ""
echo "📊 Contract addresses should be available in the broadcast logs above."

# Extract contract addresses to deployment.json
echo "📝 Extracting contract addresses..."
cd /workspace
node extract-addresses.js

echo "✅ All done! Check deployment.json for contract addresses."
