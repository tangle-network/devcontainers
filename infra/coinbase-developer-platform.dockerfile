FROM base-system:latest

# NPM global packages (as root)
USER root
RUN npm install -g @aave/core-v3 @aave/deploy-v3 @coinbase/coinbase-sdk @ethereumjs/common @radix-ui/react-icons @radix-ui/react-slot @shadcn/ui @vercel/analytics @vercel/edge bluebird class-variance-authority clsx dotenv eth-sig-util ethereumjs-tx ethereumjs-util ethers json5 jsondiffpatch lucide-react next react react-dom react-icons tailwind-merge tailwindcss-animate viem
USER project

LABEL description="coinbase-developer-platform-typescript infrastructure layer"
