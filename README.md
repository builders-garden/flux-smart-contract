# Flux Smart Contract

This project contains smart contracts for the Flux subscription system and an ENS Gateway. It's built using Hardhat and includes contracts for managing subscriptions (aka recurring payments) and off-chainresolving ENS names.

## Project Structure

- `contracts/`: Contains the Solidity smart contracts
- `test/`: Contains the test files for the contracts
- `ignition/`: Contains Hardhat Ignition deployment modules
- `hardhat.config.ts`: Hardhat configuration file

## Key Contracts

1. **FluxSubs**: Manages subscriptions for recurring payments.
2. **OffchainResolver**: Implements an ENS resolver that directs queries to a CCIP read gateway.

## Setup

1. Install dependencies:
   ```
   npm install
   ```

2. Compile contracts:
   ```
   npx hardhat compile
   ```

3. Run tests:
   ```
   npx hardhat test
   ```

## Contract Addresses

- ENS Gateway (Ethereum Mainnet): 0xb03B678fed1E379ef9D59F1e48d99D0370F35028

- Flux Subscriptions (Sei): 0xea6f7e3978ae26798c1d508957EAAD439bbeF5f4
- Flux Subscriptions (Mantle): 0xea6f7e3978ae26798c1d508957EAAD439bbeF5f4
- Flux Subscriptions (Celo): 0xF69671827C264d9A6E7CF30970015c3692Fc1d97
- Flux Subscriptions (Base): 0x1ee31c573296354aE74728035b276Bc44681bbcA