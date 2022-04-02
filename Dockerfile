FROM python:3.10-slim
ARG kubent_version=0.5.1

RUN mkdir /app && cd / && apt update && apt install -y wget dumb-init && wget https://github.com/doitintl/kube-no-trouble/releases/download/${kubent_version}/kubent-${kubent_version}-linux-amd64.tar.gz && tar -xzvf kubent-${kubent_version}-linux-amd64.tar.gz && rm kubent-${kubent_version}-linux-amd64.tar.gz && useradd -m runner
USER runner
RUN cd /tmp && wget https://dl.k8s.io/release/v1.23.0/bin/linux/amd64/kubectl && chmod +x /tmp/kubectl
USER root
COPY requirements.txt /app
RUN pip install -r /app/requirements.txt
COPY run.py /app
COPY run.sh /app
USER runner
ENTRYPOINT ["/usr/bin/dumb-init", "bash", "/app/run.sh"]
