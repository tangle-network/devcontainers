FROM scientific-python:latest

USER root
RUN pip3 install --no-cache-dir --break-system-packages torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu && \
    pip3 install --no-cache-dir --break-system-packages transformers datasets tokenizers accelerate peft diffusers safetensors huggingface_hub && \
    pip3 install --no-cache-dir --break-system-packages sentencepiece protobuf && \
    python3 -c 'import transformers; print(f"Transformers {transformers.__version__}")'

USER project

LABEL description="huggingface-cpu infrastructure layer"
