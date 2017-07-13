FROM ubuntu:17.04
MAINTAINER vvakame <vvakame@gmail.com>

# GAE/Go build & testing environment for Circle CI 2.0

RUN mkdir /work
WORKDIR /work

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        tzdata xvfb \
        curl ca-certificates \
        build-essential git unzip \
        python && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# setup Google Cloud SDK
ENV PATH=/work/google-cloud-sdk/bin:$PATH
RUN curl -o google-cloud-sdk.tar.gz https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-158.0.0-linux-x86_64.tar.gz && \
    tar -zxvf google-cloud-sdk.tar.gz && \
    rm google-cloud-sdk.tar.gz && \
    ./google-cloud-sdk/install.sh --quiet && \
    gcloud components update --quiet && \
    gcloud --quiet components install app-engine-go 
# RUN gcloud --quiet components install docker-credential-gcr kubectl alpha beta

# setup GAE/Go Standard Environment SDK
ENV PATH=$PATH:/work/go_appengine
RUN curl -o go_appengine_sdk.zip https://storage.googleapis.com/appengine-sdks/featured/go_appengine_sdk_linux_amd64-1.9.55.zip && \
    unzip go_appengine_sdk.zip && \
    rm go_appengine_sdk.zip

# setup go environment
ENV PATH=$PATH:/go/bin:/usr/local/go/bin
ENV GOPATH=/go
RUN curl -o go.tar.gz https://storage.googleapis.com/golang/go1.8.3.linux-amd64.tar.gz && \
    tar -zxvf go.tar.gz && \
    mv go /usr/local && \
    rm go.tar.gz

# setup node.js environment
## Why exec `npm install -g npm@latest`? see https://github.com/npm/npm/issues/16896
ENV PATH=/root/.nodebrew/current/bin:$PATH
RUN curl -L git.io/nodebrew | perl - setup && nodebrew install-binary v8 && nodebrew use v8 && \
    npm install -g npm@latest
