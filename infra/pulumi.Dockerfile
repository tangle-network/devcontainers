FROM base-system:latest

USER root
RUN curl -fsSL https://get.pulumi.com | sh && \
    mv /root/.pulumi/bin/* /usr/local/bin/ && \
    python3 -m pip install --no-cache-dir --break-system-packages --ignore-installed --upgrade pip && \
    python3 -m pip install --no-cache-dir --break-system-packages --ignore-installed pulumi pulumi-aws pulumi-gcp pulumi-kubernetes && \
    pulumi version

USER agent

USER root
RUN npm install -g @pulumi/pulumi @pulumi/aws @pulumi/gcp @pulumi/azure-native @pulumi/kubernetes
USER agent

LABEL description="pulumi infrastructure layer"
