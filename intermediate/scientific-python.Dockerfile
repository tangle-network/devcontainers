FROM base-system:latest

USER root
RUN pip3 install --no-cache-dir --break-system-packages \
    numpy scipy pandas matplotlib seaborn plotly \
    scikit-learn scikit-image \
    jupyter jupyterlab ipython notebook \
    pillow opencv-python-headless \
    h5py pyarrow fastparquet \
    tqdm rich typer click \
    httpx aiohttp requests \
    pydantic pydantic-settings \
    python-dotenv PyYAML toml \
    && jupyter --version

USER project

LABEL description="Scientific Python intermediate layer (NumPy, SciPy, Pandas, Jupyter, ML basics)"
