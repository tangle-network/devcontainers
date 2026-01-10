FROM foundry:latest

ENV     ENTRYPOINT_V06=0x5FF137D4b0FDCD49DcA30c7CF57E578a026d2789 \
    ENTRYPOINT_V07=0x0000000071727De22E5E9d8BAf0edAc6f37da032 \
    BASE_SEPOLIA_RPC=https://sepolia.base.org \
    TEST_MNEMONIC=test test test test test test test test test test test junk \
    BUNDLER_RPC=http://localhost:4337

USER root
RUN mkdir -p /home/project/.aa-dev/scripts /home/project/.aa-dev/contracts && \
    echo '#!/bin/bash\n# Start the full AA development stack (anvil + bundler)\necho "=== Account Abstraction Development Stack ==="\necho ""\necho "Starting Base Sepolia fork with pre-funded accounts..."\nanvil --fork-url https://sepolia.base.org --chain-id 84532 --balance 10000 --accounts 10 --mnemonic "test test test test test test test test test test test junk" --port 8545 &\nANVIL_PID=$!\nsleep 3\necho "Anvil running on http://localhost:8545"\necho ""\necho "Starting Alto bundler on port 4337..."\nnpx @pimlico/alto --rpc-url http://127.0.0.1:8545 --entry-points 0x0000000071727De22E5E9d8BAf0edAc6f37da032 --port 4337 &\nBUNDLER_PID=$!\nsleep 2\necho "Bundler running on http://localhost:4337"\necho ""\necho "=== Test Accounts ==="\necho "Account 0 (Bundler Signer): 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266"\necho "Private Key: 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80"\necho ""\necho "=== Contract Addresses ==="\necho "EntryPoint v0.7: 0x0000000071727De22E5E9d8BAf0edAc6f37da032"\necho "EntryPoint v0.6: 0x5FF137D4b0FDCD49DcA30c7CF57E578a026d2789"\necho ""\necho "Press Ctrl+C to stop all services..."\nfunction cleanup { kill $ANVIL_PID $BUNDLER_PID 2>/dev/null; exit 0; }\ntrap cleanup SIGINT SIGTERM\nwait' > /home/project/.aa-dev/start-aa-stack.sh && \
    echo '#!/bin/bash\n# Deploy a simple verifying paymaster for testing\necho "Deploying test verifying paymaster..."\n# This is a placeholder - in production you would deploy actual paymaster contracts\necho "For production paymasters, see: https://docs.pimlico.io/paymaster"\necho ""\necho "Available paymaster options:"\necho "1. Pimlico Paymaster (hosted): https://api.pimlico.io/v2/base-sepolia/rpc?apikey=YOUR_KEY"\necho "2. Coinbase Smart Wallet (gasless for eligible txs)"\necho "3. Deploy your own VerifyingPaymaster contract"' > /home/project/.aa-dev/scripts/deploy-paymaster.sh && \
    echo '#!/bin/bash\n# Show AA stack info\necho "=== Account Abstraction Stack Info ==="\necho ""\necho "EntryPoint v0.7: 0x0000000071727De22E5E9d8BAf0edAc6f37da032"\necho "EntryPoint v0.6: 0x5FF137D4b0FDCD49DcA30c7CF57E578a026d2789"\necho ""\necho "Bundler Endpoints:"\necho "  Local Alto: http://localhost:4337"\necho "  Pimlico: https://api.pimlico.io/v2/base-sepolia/rpc?apikey=YOUR_KEY"\necho "  Alchemy: https://base-sepolia.g.alchemy.com/v2/YOUR_KEY"\necho ""\necho "Smart Account Factories (Base Sepolia):"\necho "  Coinbase Smart Wallet: 0x0BA5ED0c6AA8c49038F819E587E2633c4A9F428a"\necho "  Safe Proxy Factory: 0xa6B71E26C5e0845f74c812102Ca7114b6a896AB2"\necho "  Kernel v3 Factory: 0x6723b44Abeec4E71eBE3232BD5B455805baDD22f"' > /home/project/.aa-dev/scripts/show-info.sh && \
    chmod +x /home/project/.aa-dev/*.sh /home/project/.aa-dev/scripts/*.sh && \
    chown -R project:project /home/project/.aa-dev

USER root
RUN npm install -g permissionless @coinbase/wallet-sdk @coinbase/onchainkit viem wagmi ethers @pimlico/alto userop @account-abstraction/sdk @account-abstraction/contracts localtunnel
USER project

# Pre-warm npm cache with project-specific packages
RUN npm cache add permissionless@latest @coinbase/wallet-sdk@latest @coinbase/onchainkit@latest @pimlico/alto@latest userop@latest @account-abstraction/sdk@latest

LABEL description="base-aa infrastructure layer"
