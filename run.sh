#!/bin/bash

/tmp/kubectl config set-cluster local --server=https://kubernetes.default.svc.cluster.local --certificate-authority /run/secrets/kubernetes.io/serviceaccount/ca.crt
/tmp/kubectl config set-credentials local --token=$(cat /run/secrets/kubernetes.io/serviceaccount/token)
/tmp/kubectl config set-context local --cluster=local --user=local
/tmp/kubectl config use-context local
rm /tmp/kubectl
exec python /app/run.py
