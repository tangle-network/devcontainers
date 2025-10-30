FROM base-system:latest

RUN pip3 install --no-cache-dir opencv-python opencv-contrib-python

LABEL description="opencv intermediate layer"
