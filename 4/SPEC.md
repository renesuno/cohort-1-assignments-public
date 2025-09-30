# MiniAMM UI Specification

## Overview
Create a UI for MiniAMM (Automated Market Maker) using Next.js with wallet connection, token operations, and liquidity management.

## Technology Stack
- Next.js
- Ethers.js v6 (blockchain interaction)
- RainbowKit (wallet connection)
- TypeChain (type-safe contract interaction)

## Network & Contract Information
- **Network**: Flare Coston2 Testnet
- **TOKEN A (MockERC20)**: `0x2203a23279483aA116C4b46Cd924171A1BC028f3`
- **TOKEN B (MockERC20)**: `0x3d2e6Bf44c8ba2DB5cC29A1536752d6F03E5e32F`
- **MiniAMM Pair**: `0xFf31A5e09143e9A8079214D1072f5F3a552f5540`
- **MiniAMMFactory**: `0x87D927A7c8dD7C99df8d5DB758512Dc7a7E667cD`

## Contract Interaction
- Use TypeChain generated types from `src/types/ethers-contracts`
- Interact with MiniAMM and MockERC20 contracts using type-safe methods only

## Core Features

### 1. Wallet Management
- [ ] Connect wallet functionality
- [ ] Disconnect wallet functionality
- [ ] Display connected wallet address

### 2. Token Operations
- [ ] Mint MockERC20 tokens
- [ ] Approve MiniAMM to spend MockERC20 tokens (for both token contracts)
- [ ] Display current MockERC20 token balances in connected wallet
- [ ] Display current MockERC20 token balances in MiniAMM contract

### 3. Swap Interface
- [ ] Token selection dropdown (choose which of the two tokens to sell)
- [ ] Amount input field (amount to sell)
- [ ] Display calculated amount to receive (using constant product formula)
- [ ] Swap execution button
- [ ] Transaction state management:
  - [ ] Disable button during transaction
  - [ ] Show loading indicator
  - [ ] Update balances after confirmation
  - [ ] Re-enable button after completion

### 4. Liquidity Management
- [ ] Add liquidity functionality (call addLiquidity function)
- [ ] Remove liquidity functionality (call removeLiquidity function)
- [ ] Display current liquidity amounts

## UI/UX Requirements
- Clean, intuitive interface
- Real-time balance updates
- Transaction status feedback
- Loading states for all async operations
- Error handling and user feedback

## Implementation Notes
- All contract interactions must use TypeChain generated types
- Follow constant product formula: x * y = k for swap calculations
- Ensure proper approval flow before swaps and liquidity operations
- Handle transaction confirmations and state updates appropriately