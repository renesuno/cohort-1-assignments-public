# MiniAMM - Automated Market Maker Implementation

## 📋 Project Overview

This project implements a minimal Automated Market Maker (AMM) on the Flare Coston2 testnet. The AMM follows the constant product formula (x * y = k) and includes two mock ERC20 tokens for testing.

## 🚀 Deployed Contracts (Flare Coston2 Testnet)

- **TokenX**: Contract Address: 0xF810ef7250F88f4BBf9fbe096386A87d265fc5F9
- **TokenY**: Contract Address: 0x44d7C28EA1BEB358A0Ca5B5622ec1CBdf6951E0B
- **MiniAMM**: Contract Address: 0x3743B343e47C62Bd1C563dEAF7620bfC4624d542

## 📁 Project Structure

```
mini-amm/
├── src/
│   ├── MockERC20.sol    # Mock ERC20 token with free minting
│   └── MiniAMM.sol      # AMM implementation
├── script/
│   └── MiniAMM.s.sol    # Deployment script
├── test/                # Test files
└── foundry.toml         # Foundry configuration
```

## 🛠️ Features

### MockERC20
- Standard ERC20 implementation using OpenZeppelin
- `freeMintTo(address to, uint256 amount)`: Mint tokens to any address
- `freeMintToSender(uint256 amount)`: Mint tokens to msg.sender

### MiniAMM
- `addLiquidity(uint256 amountX, uint256 amountY)`: Add liquidity to the pool
  - First liquidity addition: Any ratio allowed
  - Subsequent additions: Must maintain existing X:Y ratio
- `swap(address tokenIn, uint256 dx)`: Swap tokens maintaining constant k
  - Automatically calculates output amount
  - Supports swapping in both directions

## ⚙️ Technical Implementation

### Key Concepts
1. **Constant Product Formula**: `k = x * y` remains constant during swaps
2. **Liquidity Provision**: Users must provide both tokens maintaining the pool ratio
3. **Price Discovery**: Price is determined by the ratio of token reserves

### Deployment Process

#### 1. Environment Setup
```bash
# Clone and install dependencies
forge install

# Create .env file
echo "PRIVATE_KEY=your_private_key_without_0x" > .env
echo "RPC_URL=https://coston2-api.flare.network/ext/bc/C/rpc" >> .env
```

#### 2. Compile Contracts
```bash
forge build
```

#### 3. Run Tests
```bash
forge test
```

#### 4. Deploy to Flare Coston2
```bash
forge script script/MiniAMM.s.sol:MiniAMMDeployment \
  --rpc-url $RPC_URL \
  --broadcast \
  -vvvv
```

## 🐛 Troubleshooting: Solidity Version Compatibility

### Problem Encountered
Initial deployment failed with the following error:
```
Warning: EIP-3855 is not supported in one or more of the RPCs used.
Unsupported Chain IDs: 114.
Contracts deployed with a Solidity version equal or higher than 0.8.20 might not work properly.
```

### Root Cause
Flare Coston2 testnet (Chain ID: 114) does not support EIP-3855 (PUSH0 opcode), which is introduced in Solidity 0.8.20. Contracts compiled with Solidity ≥0.8.20 will fail to deploy on this network.

### Solution Applied

1. **Downgrade Solidity Version**
   ```toml
   # foundry.toml
   [profile.default]
   solc = "0.8.19"  # Changed from "0.8.30"
   ```

2. **Update Contract Pragmas**
   ```solidity
   // All .sol files
   pragma solidity 0.8.19;  // Changed from ^0.8.30
   ```

3. **Install Compatible OpenZeppelin**
   ```bash
   # Remove incompatible version
   forge remove openzeppelin-contracts-upgradeable -f
   
   # Install version compatible with Solidity 0.8.19
   forge install OpenZeppelin/openzeppelin-contracts@v4.9.3
   ```

4. **Update Remappings**
   ```toml
   # foundry.toml
   remappings = [
       "@openzeppelin/contracts/=lib/openzeppelin-contracts/contracts/",
   ]
   ```

5. **Clean and Rebuild**
   ```bash
   forge clean
   rm -rf cache out
   forge build
   ```

### Lessons Learned
- Always check network compatibility with Solidity versions
- EVM networks may not support latest opcodes immediately
- Flare Coston2 requires Solidity <0.8.20 for successful deployment

## 🔧 Development Commands

```bash
# Install dependencies
forge install

# Compile contracts
forge build

# Run tests
forge test

# Run tests with gas reporting
forge test --gas-report

# Format code
forge fmt

# Clean build artifacts
forge clean
```

## 📚 Resources

- [Flare Network Documentation](https://docs.flare.network/)
- [Foundry Book](https://book.getfoundry.sh/)
- [OpenZeppelin Contracts](https://docs.openzeppelin.com/contracts/)
- [EIP-3855 Details](https://eips.ethereum.org/EIPS/eip-3855)

## 📄 License

MIT
