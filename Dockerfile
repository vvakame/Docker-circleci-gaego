FROM ubuntu:17.10
LABEL maintainer="vvakame@gmail.com"

# GAE/Go build & testing environment for Circle CI 2.0

ENV GCLOUD_SDK_VERSION 179.0.0
ENV GOLANG_VERSION 1.8.5
ENV DEP_VERSION 0.3.2
ENV NODEJS_VERSION v8

RUN mkdir /work
WORKDIR /work

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        tzdata xvfb vim \
        curl ca-certificates \
        build-essential git unzip \
        python && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# setup Google Cloud SDK & GAE/Go Environment
ENV PATH=/work/google-cloud-sdk/bin:/work/google-cloud-sdk/platform/google_appengine:$PATH
RUN curl -o google-cloud-sdk.tar.gz https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-${GCLOUD_SDK_VERSION}-linux-x86_64.tar.gz && \
    tar -zxf google-cloud-sdk.tar.gz && \
    rm google-cloud-sdk.tar.gz && \
    ./google-cloud-sdk/install.sh --quiet && \
    gcloud --quiet components install app-engine-go && \
    chmod +x /work/google-cloud-sdk/platform/google_appengine/goapp /work/google-cloud-sdk/platform/google_appengine/appcfg.py
# RUN gcloud --quiet components install docker-credential-gcr kubectl alpha beta

# setup go environment
ENV PATH=$PATH:/go/bin:/usr/local/go/bin
ENV GOPATH=/go
RUN curl -o go.tar.gz https://storage.googleapis.com/golang/go${GOLANG_VERSION}.linux-amd64.tar.gz && \
    tar -zxf go.tar.gz && \
    mv go /usr/local && \
    rm go.tar.gz

# setup golang/dep
RUN curl -fsSL -o /usr/local/bin/dep https://github.com/golang/dep/releases/download/v${DEP_VERSION}/dep-linux-amd64 && \
    chmod +x /usr/local/bin/dep

# setup node.js environment
ENV PATH=/root/.nodebrew/current/bin:$PATH
RUN curl -L git.io/nodebrew | perl - setup && \
    nodebrew install-binary ${NODEJS_VERSION} && \
    nodebrew use ${NODEJS_VERSION}

# setup browser environment
RUN apt-get update && \
    apt-get install -y --no-install-recommends libappindicator1 && \
    curl --silent --show-error --location --fail --retry 3 -o google-chrome-stable_current_amd64.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
    (dpkg -i google-chrome-stable_current_amd64.deb || apt-get -fy install) && \
    rm -rf google-chrome-stable_current_amd64.deb && \
    sed -i 's|HERE/chrome"|HERE/chrome" --disable-setuid-sandbox --no-sandbox|g' /opt/google/chrome/google-chrome && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
