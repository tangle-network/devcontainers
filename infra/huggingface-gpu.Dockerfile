FROM cuda:latest

USER root
RUN pip3 install --no-cache-dir torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu124 && \
    pip3 install --no-cache-dir transformers datasets tokenizers accelerate peft diffusers safetensors huggingface_hub && \
    pip3 install --no-cache-dir bitsandbytes sentencepiece protobuf && \
    pip3 install --no-cache-dir numpy scipy pandas matplotlib seaborn scikit-learn jupyter jupyterlab && \
    python3 -c 'import transformers; print(f"Transformers {transformers.__version__}")'

USER project

LABEL description="huggingface-gpu infrastructure layer"
