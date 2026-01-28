FROM base-system:latest

# Vercel AI SDK with all providers pre-cached
# Providers are cached but not installed - fast install when needed, minimal storage

USER root

# Install core AI SDK globally (minimal footprint)
RUN npm install -g ai @ai-sdk/provider @ai-sdk/provider-utils

# Pre-warm npm cache with ALL AI SDK providers
# These are cached only - not installed globally - so they don't consume storage
# but will install instantly when the user runs `npm install @ai-sdk/openai` etc.
RUN npm cache add \
    # Core
    ai@latest \
    @ai-sdk/provider@latest \
    @ai-sdk/provider-utils@latest \
    @ai-sdk/ui-utils@latest \
    @ai-sdk/react@latest \
    @ai-sdk/svelte@latest \
    @ai-sdk/vue@latest \
    @ai-sdk/solid@latest \
    # OpenAI
    @ai-sdk/openai@latest \
    @ai-sdk/openai-compatible@latest \
    # Anthropic
    @ai-sdk/anthropic@latest \
    # Google
    @ai-sdk/google@latest \
    @ai-sdk/google-vertex@latest \
    # AWS
    @ai-sdk/amazon-bedrock@latest \
    # Azure
    @ai-sdk/azure@latest \
    # Mistral
    @ai-sdk/mistral@latest \
    # Cohere
    @ai-sdk/cohere@latest \
    # Groq
    @ai-sdk/groq@latest \
    # Perplexity
    @ai-sdk/perplexity@latest \
    # Fireworks
    @ai-sdk/fireworks@latest \
    # Together
    @ai-sdk/togetherai@latest \
    # xAI (Grok)
    @ai-sdk/xai@latest \
    # DeepSeek
    @ai-sdk/deepseek@latest \
    # Cerebras
    @ai-sdk/cerebras@latest \
    # LangChain adapter
    @ai-sdk/langchain@latest \
    # Related SDKs users often want
    openai@latest \
    @anthropic-ai/sdk@latest \
    @google/generative-ai@latest \
    @mistralai/mistralai@latest \
    cohere-ai@latest \
    groq-sdk@latest || true

USER agent

LABEL description="Vercel AI SDK with all providers pre-cached for instant installation"
