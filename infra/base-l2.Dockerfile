FROM foundry:latest

ENV     BASE_MAINNET_RPC=https://mainnet.base.org \
    BASE_SEPOLIA_RPC=https://sepolia.base.org \
    ENTRYPOINT_ADDRESS=0x0000000071727De22E5E9d8BAf0edAc6f37da032 \
    TEST_MNEMONIC=test test test test test test test test test test test junk \
    USDC_BASE_SEPOLIA=0x036CbD53842c5426634e7929541eC2318f3dCF7e

USER root
RUN mkdir -p /home/project/.base-dev/scripts && \
    echo '#!/bin/bash\n# Start anvil with pre-funded accounts (10000 ETH each)\n# Mnemonic: test test test test test test test test test test test junk\n# Account 0: 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266\n# Account 1: 0x70997970C51812dc3A010C7d01b50e0d17dc79C8\necho "Starting Base Sepolia fork with pre-funded accounts..."\nanvil --fork-url https://sepolia.base.org --chain-id 84532 --balance 10000 --accounts 10 --mnemonic "test test test test test test test test test test test junk" "$@"' > /home/project/.base-dev/start-base-fork.sh && \
    echo '#!/bin/bash\n# Mint test USDC to an address on local anvil\nADDRESS=${1:-0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266}\nAMOUNT=${2:-1000000000000}  # 1M USDC (6 decimals)\nRPC=${3:-http://127.0.0.1:8545}\nUSCD=0x036CbD53842c5426634e7929541eC2318f3dCF7e\necho "Minting $AMOUNT USDC to $ADDRESS..."\n# Impersonate USDC minter and mint\ncast rpc anvil_impersonateAccount 0x...  --rpc-url $RPC 2>/dev/null || true\ncast send $USDC "transfer(address,uint256)" $ADDRESS $AMOUNT --rpc-url $RPC --unlocked --from 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 2>/dev/null\necho "Done. Check balance: cast call $USDC balanceOf(address)(uint256) $ADDRESS --rpc-url $RPC"' > /home/project/.base-dev/scripts/mint-usdc.sh && \
    echo '#!/bin/bash\n# Show test account info\necho "=== Pre-funded Test Accounts ==="\necho "Mnemonic: test test test test test test test test test test test junk"\necho ""\necho "Account 0: 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266"\necho "Private Key: 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80"\necho ""\necho "Account 1: 0x70997970C51812dc3A010C7d01b50e0d17dc79C8"\necho "Private Key: 0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d"\necho ""\necho "Account 2: 0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC"\necho "Private Key: 0x5de4111afa1a4b94908f83103eb1f1706367c2e68ca870fc3fb9a804cdab365a"\necho ""\necho "All accounts have 10000 ETH on local anvil fork."' > /home/project/.base-dev/scripts/show-accounts.sh && \
    chmod +x /home/project/.base-dev/*.sh /home/project/.base-dev/scripts/*.sh && \
    chown -R project:project /home/project/.base-dev

USER project

USER root
RUN npm install -g @coinbase/onchainkit @coinbase/wallet-sdk @coinbase/cdp-sdk @coinbase/agentkit frames.js @farcaster/hub-nodejs permissionless viem wagmi ethers localtunnel
USER project

# Pre-warm npm cache with project-specific packages
RUN npm cache add @coinbase/onchainkit@latest @coinbase/wallet-sdk@latest @coinbase/cdp-sdk@latest @coinbase/agentkit@latest frames.js@latest permissionless@latest @x402/fetch@latest @x402/axios@latest @x402/express@latest @rainbow-me/rainbowkit@latest

LABEL description="base-l2 infrastructure layer"
