FROM scientific-python:latest

USER root
RUN pip3 install --no-cache-dir --break-system-packages openai transformers accelerate && \
    echo 'vLLM CPU dependencies installed (use vllm-gpu for full vLLM support)'

USER project

LABEL description="vllm-cpu infrastructure layer"
