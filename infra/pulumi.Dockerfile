FROM base-system:latest

USER root
RUN curl -fsSL https://get.pulumi.com | sh && \
    mv /root/.pulumi/bin/* /usr/local/bin/ && \
    pip3 install --no-cache-dir --break-system-packages pulumi pulumi-aws pulumi-gcp pulumi-kubernetes && \
    pulumi version

USER project

USER root
RUN npm install -g @pulumi/pulumi @pulumi/aws @pulumi/gcp @pulumi/kubernetes
USER project

LABEL description="pulumi infrastructure layer"
