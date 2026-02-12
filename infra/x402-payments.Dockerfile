FROM foundry:latest

ENV     BASE_MAINNET_RPC=https://mainnet.base.org \
    BASE_SEPOLIA_RPC=https://sepolia.base.org \
    TEST_MNEMONIC="test test test test test test test test test test test junk" \
    USDC_BASE_SEPOLIA=0x036CbD53842c5426634e7929541eC2318f3dCF7e \
    USDC_BASE_MAINNET=0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913 \
    X402_FACILITATOR_TESTNET=https://x402.org/facilitator \
    X402_FACILITATOR_MAINNET=https://api.cdp.coinbase.com/platform/v2/x402 \
    X402_CHAIN_ID_BASE_SEPOLIA=eip155:84532 \
    X402_CHAIN_ID_BASE_MAINNET=eip155:8453

USER root
RUN mkdir -p /home/agent/.x402-dev/scripts && \
    echo '#!/bin/bash\n# Start the full x402 development stack\necho "=== x402 Payment Development Stack ==="\necho ""\necho "Starting Base Sepolia fork with pre-funded accounts..."\nanvil --fork-url https://sepolia.base.org --chain-id 84532 --balance 10000 --accounts 10 --mnemonic "test test test test test test test test test test test junk" --port 8545 &\nANVIL_PID=$!\nsleep 3\necho "Anvil running on http://localhost:8545"\necho ""\necho "=== x402 Facilitator Endpoints ==="\necho "Testnet: https://x402.org/facilitator"\necho "Mainnet: https://api.cdp.coinbase.com/platform/v2/x402"\necho ""\necho "=== Chain IDs ==="\necho "Base Sepolia: eip155:84532"\necho "Base Mainnet: eip155:8453"\necho ""\necho "=== Test Accounts ==="\necho "Account 0: 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266"\necho "Private Key: 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80"\necho ""\necho "=== USDC Addresses ==="\necho "Base Sepolia: 0x036CbD53842c5426634e7929541eC2318f3dCF7e"\necho "Base Mainnet: 0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913"\necho ""\necho "Press Ctrl+C to stop..."\nwait $ANVIL_PID' > /home/agent/.x402-dev/start-x402-dev.sh && \
    echo '#!/bin/bash\n# Show x402 configuration\necho "=== x402 Payment Protocol Configuration ==="\necho ""\necho "Facilitator Endpoints:"\necho "  Testnet (public):  https://x402.org/facilitator"\necho "  Mainnet (CDP):     https://api.cdp.coinbase.com/platform/v2/x402"\necho ""\necho "Required Environment Variables (mainnet):"\necho "  CDP_API_KEY_ID=your-api-key-id"\necho "  CDP_API_KEY_SECRET=your-api-key-secret"\necho ""\necho "Supported Chains:"\necho "  Base Sepolia:  eip155:84532"\necho "  Base Mainnet:  eip155:8453"\necho "  Solana Devnet: solana:EtWTRABZaYq6iMfeYKouRu166VU2xqa1"\necho "  Solana Main:   solana:5eykt4UsFv8P8NJdTREpY1vzqKqZKvdp"\necho ""\necho "USDC Addresses:"\necho "  Base Sepolia: 0x036CbD53842c5426634e7929541eC2318f3dCF7e"\necho "  Base Mainnet: 0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913"\necho ""\necho "Documentation: https://docs.cdp.coinbase.com/x402/welcome"' > /home/agent/.x402-dev/scripts/show-config.sh && \
    echo '#!/bin/bash\n# Example x402 seller server setup\ncat << '"'"'EXAMPLE'"'"'\nimport { paymentMiddleware } from "@x402/express";\nimport { facilitatorClient } from "@coinbase/x402";\nimport express from "express";\n\nconst app = express();\n\n// Testnet configuration\nconst facilitator = facilitatorClient({\n  url: "https://x402.org/facilitator",\n});\n\n// Protected endpoint requiring payment\napp.get("/premium-content",\n  paymentMiddleware(facilitator, {\n    payTo: "0xYourWalletAddress",\n    amount: "100000", // 0.10 USDC (6 decimals)\n    asset: "USDC",\n    network: "eip155:84532", // Base Sepolia\n  }),\n  (req, res) => {\n    res.json({ content: "Premium content here!" });\n  }\n);\n\napp.listen(3000);\nEXAMPLE' > /home/agent/.x402-dev/scripts/example-seller.sh && \
    chmod +x /home/agent/.x402-dev/*.sh /home/agent/.x402-dev/scripts/*.sh && \
    chown -R agent:agent /home/agent/.x402-dev

USER agent

USER root
RUN npm install -g @coinbase/x402 @x402/fetch @x402/axios @x402/express @x402/hono @x402/core @x402/evm @coinbase/cdp-sdk @coinbase/wallet-sdk viem wagmi ethers hono express localtunnel
USER agent

# Pre-warm npm cache with project-specific packages
RUN npm cache add @coinbase/x402@latest @x402/fetch@latest @x402/axios@latest @x402/express@latest @x402/hono@latest @x402/core@latest @x402/evm@latest @coinbase/cdp-sdk@latest permissionless@latest || true

LABEL description="x402-payments infrastructure layer"
