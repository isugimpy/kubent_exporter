FROM python:3.10-slim
ARG kubent_version=0.5.1

RUN mkdir /app && cd / && apt update && apt install -y wget dumb-init && wget https://github.com/doitintl/kube-no-trouble/releases/download/${kubent_version}/kubent-${kubent_version}-linux-amd64.tar.gz && tar -xzvf kubent-${kubent_version}-linux-amd64.tar.gz && rm kubent-${kubent_version}-linux-amd64.tar.gz && useradd -m runner && cd /tmp && wget https://dl.k8s.io/release/v1.23.0/bin/linux/amd64/kubectl && chmod +x /tmp/kubectl && /tmp/kubectl config set-cluster local --server=https://kubernetes.default.svc.cluster.local --certificate-authority /run/secrets/kubernetes.io/serviceaccount/ca.crt && /tmp/kubectl config set-credentials local --token=$(cat /run/secrets/kubernetes.io/serviceaccount/token) && /tmp/kubectl config set-context local --cluster=local --user=local && /tmp/kubectl config use-context local && rm /tmp/kubectl
COPY requirements.txt /app
RUN pip install -r /app/requirements.txt
COPY run.py /app
USER runner
ENTRYPOINT ["/usr/bin/dumb-init", "python", "/app/run.py"]
