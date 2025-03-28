# ChainCanvas NFT Smart Contract

## Overview

ChainCanvas is an advanced NFT (Non-Fungible Token) smart contract built on the Stacks blockchain, providing robust and flexible NFT management with additional features beyond standard implementations.

## 🌟 Key Features

### 1. Enhanced Minting
- Mint NFTs with built-in royalty mechanisms
- Set custom royalty percentages for creators
- Validate and restrict royalty parameters

### 2. NFT Burning
- Ability to permanently burn NFTs
- Prevents re-use of burned token IDs
- Provides clear ownership and burn tracking

### 3. Royalty Management
- Per-token royalty configuration
- Supports up to 50% royalty percentage
- Flexible royalty receiver assignment

## 🛠 Core Functions

### Mint with Royalty
```clarity
(mint-with-royalty 
  recipient 
  token-uri 
  royalty-receiver
  royalty-percentage
)
```
- Create new NFTs with embedded royalty information
- Validate recipient and token details
- Set royalty receiver and percentage

### Burn NFT
```clarity
(burn-nft token-id)
```
- Permanently remove an NFT from circulation
- Verify ownership before burning
- Prevent re-burning of tokens

### Transfer NFT
```clarity
(transfer token-id sender recipient)
```
- Secure NFT transfers
- Prevent transfers to restricted addresses
- Validate ownership and token status

## 🔒 Security Features

- Owner-only minting
- Transfer restrictions
- Royalty percentage limits
- Burned token tracking
- Comprehensive error handling

## 📦 Prerequisites

- Stacks Blockchain
- Compatible Stacks wallet
- Clarity smart contract support

## 🚀 Deployment

1. Compile the Clarity smart contract
2. Deploy to Stacks blockchain
3. Interact via Stacks-compatible interfaces

## 🛡️ Error Codes

- `ERR-NOT-AUTHORIZED (u1)`: Unauthorized action
- `ERR-INVALID-RECIPIENT (u2)`: Invalid transfer recipient
- `ERR-TOKEN-NOT-FOUND (u3)`: Token does not exist
- `ERR-ALREADY-BURNED (u4)`: Token already burned
- `ERR-INVALID-ROYALTY (u5)`: Invalid royalty parameters

## 💡 Usage Example

```clarity
;; Mint an NFT with 10% royalty
(contract-call? .nft-contract mint-with-royalty 
  recipient 
  "https://example.com/nft-metadata" 
  royalty-receiver 
  u10
)

;; Burn a specific NFT
(contract-call? .nft-contract burn-nft u42)

;; Get royalty information
(contract-call? .nft-contract get-royalty-info u42)
```

## 📝 Contributing

1. Fork the repository
2. Create a feature branch
3. Commit changes
4. Submit a pull request


## 🏷️ Version

**Current Version**: 1.0.0  
**Blockchain**: Stacks  
**Language**: Clarity