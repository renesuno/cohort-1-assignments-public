#!/bin/sh
set -e
echo "🚀 Starting smart contract deployment..." 

# Configure git for container environment
echo "🔧 Configuring git..."
git config --global --add safe.directory '*'
git config --global user.name "Docker Deployer"
git config --global user.email "deployer@docker.local"

# Wait for geth-init to complete prefunding     
echo "⏳ Waiting for geth-init to complete prefunding..."
until [ -f "/shared/geth-init-complete" ]; do   
  echo "Waiting for geth-init-complete file..." 
  sleep 2
done
echo "✅ Prefunding completed, proceeding with deployment..."

# Clean up and clone repository fresh
echo "🧹 Cleaning up previous repository..."    
rm -rf /workspace/mock-erc20-mini-amm   
cd /workspace

echo "📥 Cloning repository..."
git clone https://github.com/renesuno/mock-erc20-mini-amm.git
cd mock-erc20-mini-amm

# Fix ownership issues
echo "🔧 Fixing repository ownership..."
git config --add safe.directory /workspace/mock-erc20-mini-amm

# Navigate to the 1a directory (if it exists, otherwise use current directory)
if [ -d "1a" ]; then
    echo "📁 Found 1a directory, entering..."
    cd 1a
else
    echo "📁 No 1a directory found, using current directory..."
fi

# Install dependencies
echo "📦 Installing dependencies..."
forge install

# Build the project
echo "🔨 Building project..."
forge build

# Deploy MiniAMM contracts only
echo "🚀 Deploying MiniAMM contracts..."
if [ -f "script/MiniAMM.s.sol" ]; then
    forge script script/MiniAMM.s.sol:MiniAMMDeployment \
        --rpc-url http://geth:8545 \
        --private-key $PRIVATE_KEY \
        --broadcast
    echo "✅ MiniAMM deployment completed!"
else
    echo "❌ MiniAMM.s.sol not found!"
    exit 1
fi

echo "📊 Checking for MiniAMM broadcast files..."
find . -path "./broadcast/MiniAMM.s.sol/1337/run-latest.json" -type f || echo "No MiniAMM broadcast file found"

# Extract contract addresses to deployment.json 
echo "📝 Extracting contract addresses..."      
cd /workspace
chmod +x extract-addresses.sh
./extract-addresses.sh

echo "✅ All done! Check deployment.json for contract addresses."