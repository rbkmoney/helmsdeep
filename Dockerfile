FROM ubuntu:18.04

ARG HELM_VERSION=3.2.0
ARG KUBECTL_VERSION=1.17.0

ENV ARM_CLIENT_ID=""
ENV ARM_CLIENT_SECRET=""
ENV ARM_SUBSCRIPTION_ID=""
ENV ARM_TENANT_ID=""
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

WORKDIR /charts

RUN apt-get update && \
    apt-get -y install curl \
      wget \
      ca-certificates \
      python3-pip \
      apt-transport-https \
      locales \
      gnupg && \
    locale-gen en_US.UTF-8 && \
    wget -P tmp/ https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz && \
    tar -zxvf tmp/helm-v${HELM_VERSION}-linux-amd64.tar.gz -C tmp/ && \
    cp tmp/linux-amd64/helm /usr/local/bin && \
    wget -P tmp/ https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl && \
    chmod +x tmp/kubectl && \
    mv tmp/kubectl /usr/local/bin/kubectl && \
    chsh -s /bin/bash && \
    ln -sf /bin/bash /bin/sh

COPY . .

RUN cd ./generic-application && \
    helm dependencies update
