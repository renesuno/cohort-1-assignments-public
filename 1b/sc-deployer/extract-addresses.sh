#!/bin/sh

# Extract contract addresses from MiniAMM broadcast file
echo "📝 Extracting MiniAMM contract addresses..."

# Look for MiniAMM broadcast file first
BROADCAST_FILE=""
if [ -f "./mock-erc20-mini-amm/broadcast/MiniAMM.s.sol/1337/run-latest.json" ]; then
    BROADCAST_FILE="./mock-erc20-mini-amm/broadcast/MiniAMM.s.sol/1337/run-latest.json"
    echo "📄 Using MiniAMM broadcast file: $BROADCAST_FILE"
else
    echo "❌ MiniAMM broadcast file not found"
    exit 1
fi

# Extract contract addresses using proper JSON parsing
echo "🔍 Extracting contract addresses from transactions..."

# Extract MockERC20 contracts (should be first two)
MOCK_ERC_0=$(grep -A 10 '"contractName": "MockERC20"' "$BROADCAST_FILE" | grep '"contractAddress":' | head -1 | sed 's/.*"contractAddress": "\([^"]*\)".*/\1/')
MOCK_ERC_1=$(grep -A 10 '"contractName": "MockERC20"' "$BROADCAST_FILE" | grep '"contractAddress":' | tail -1 | sed 's/.*"contractAddress": "\([^"]*\)".*/\1/')

# Extract MiniAMM contract
MINI_AMM=$(grep -A 10 '"contractName": "MiniAMM"' "$BROADCAST_FILE" | grep '"contractAddress":' | sed 's/.*"contractAddress": "\([^"]*\)".*/\1/')

echo "🔍 Found contract addresses:"
echo "  MockERC20 #0: $MOCK_ERC_0"
echo "  MockERC20 #1: $MOCK_ERC_1"  
echo "  MiniAMM: $MINI_AMM"

# Create deployment.json with proper formatting
cat > ./deployment.json << EOF
{
    "timestamp": "$(date -Iseconds)",
    "source_file": "$BROADCAST_FILE",
    "contracts": {
        "mock_erc_0": "$MOCK_ERC_0",
        "mock_erc_1": "$MOCK_ERC_1",
        "mini_amm": "$MINI_AMM"
    }
}
EOF

echo "✅ Contract addresses extracted to deployment.json:"
cat ./deployment.json