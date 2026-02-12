FROM base-system:latest

USER root
RUN curl -fsSL https://get.pulumi.com | sh && \
    mv /root/.pulumi/bin/* /usr/local/bin/ && \
    pip3 install --no-cache-dir --break-system-packages pulumi pulumi-aws pulumi-gcp pulumi-kubernetes && \
    pulumi version

USER agent

USER root
RUN npm install -g @pulumi/pulumi @pulumi/aws @pulumi/gcp @pulumi/azure-native @pulumi/kubernetes
USER agent

LABEL description="pulumi infrastructure layer"
