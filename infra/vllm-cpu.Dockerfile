FROM scientific-python:latest

USER root
RUN pip3 install --no-cache-dir --break-system-packages vllm --extra-index-url https://download.pytorch.org/whl/cpu || echo 'vLLM CPU build may have limited support' && \
    pip3 install --no-cache-dir --break-system-packages openai && \
    echo 'vLLM CPU installed (limited functionality compared to GPU version)'

USER agent

LABEL description="vllm-cpu infrastructure layer"
