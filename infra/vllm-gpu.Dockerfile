FROM cuda:latest

USER root
RUN pip3 install --no-cache-dir vllm && \
    pip3 install --no-cache-dir openai numpy scipy pandas && \
    python3 -c 'import vllm; print(f"vLLM {vllm.__version__}")'

USER project

LABEL description="vllm-gpu infrastructure layer"
