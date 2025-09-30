# Project Specification: Local Docker Compose Environment

## Overview
Set up a local environment running on Docker Compose with reverse proxy, tunnel, EVM node, explorer, and graph stack.

## Architecture Components

### Services
- **Caddy**: Reverse proxy routing all services to single origin
- **ngrok**: Tunnel to expose local environment to Internet
- **Geth**: EVM node running blockchain
- **Smart Contracts Deployer**: Ephemeral container deploying assignment 1A contracts
- **Deployment Server**: Caddy hosting contract addresses JSON
- **Blockscout**: Blockchain explorer UI
- **Graph Stack**: IPFS, Postgres, Redis, Graph Node for data indexing

### Endpoints
All accessible via `https://yourorigin.com`:
- `/deployment` → Smart contracts deployment server
- `/explorer` → Blockscout explorer
- `/rpc` → Geth RPC service
- `/graph-playground` → Graph node GraphQL playground

## Implementation Checklist

- [x] 1. Review existing project structure and assignment 1A
- [x] 2. Set up ngrok account and obtain domain/auth token (Complete - stored in .env)
- [x] 3. Create docker-compose.yml with all required services
- [x] 4. Configure Geth initialization script (prefund.js)
- [x] 5. Create Geth entrypoint script for EVM node
- [x] 6. Set up smart contracts deployer container
- [x] 7. Configure smart contracts deployment server (Caddy)
- [x] 8. Set up Blockscout explorer with docker-compose
- [x] 9. Configure Graph stack (IPFS, Postgres, Redis, Graph Node)
- [x] 10. Create Caddyfile for reverse proxy routing
- [x] 11. Configure ngrok tunnel in docker-compose
- [x] 12. Test all endpoints (locally - ngrok needs session fix)

## Technical Details

### Geth Initialization
- Write prefund.js to prefund accounts with known private keys
- Reference: Geth documentation for account prefunding

### Blockscout Setup
- Run separate docker-compose file alongside main compose
- Connect to local Geth EVM node for blockchain indexing
- Reference: Blockscout documentation

### Graph Stack
- Graph node connects to: IPFS, Redis, Postgres, Geth
- Expected behavior: Show "Access deployed subgraphs by deployment ID" message
- No actual subgraph indexing required initially

### Reverse Proxy Routing
Example routing pattern:
- localhost:5000 (Geth RPC) → https://myorigin.com/rpc
- localhost:6000 (Explorer) → https://myorigin.com/explorer

## Notes
- Smart contracts deployer is ephemeral (runs once and stops)
- Deployment server hosts JSON with contract addresses
- Graph stack should expose GraphQL playground without indexing data initially