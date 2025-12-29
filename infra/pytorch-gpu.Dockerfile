FROM cuda:latest

USER root
RUN pip3 install --no-cache-dir torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu124 && \
    pip3 install --no-cache-dir numpy scipy pandas matplotlib seaborn scikit-learn jupyter jupyterlab && \
    python3 -c 'import torch; print(f"PyTorch {torch.__version__}, CUDA available: {torch.cuda.is_available()}")'

USER project

LABEL description="pytorch-gpu infrastructure layer"
