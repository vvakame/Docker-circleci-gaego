FROM ubuntu:18.04
LABEL maintainer="vvakame@gmail.com"

# GAE/Go build & testing environment for Circle CI 2.0

ENV GCLOUD_SDK_VERSION 224.0.0
ENV GOLANG_VERSION 1.11.2
ENV DEP_VERSION 0.5.0
ENV NODEJS_VERSION v10

RUN mkdir /work
WORKDIR /work

RUN apt-get update && \
    ln -sf /usr/share/zoneinfo/UTC /etc/localtime && \
    apt-get install -y --no-install-recommends \
        tzdata xvfb vim \
        curl ca-certificates \
        build-essential git unzip \
        ssh \
        python \
        lsb-release gnupg && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# setup Google Cloud SDK & GAE/Go Environment
ENV PATH=$PATH:/usr/lib/google-cloud-sdk/platform/google_appengine
RUN export CLOUD_SDK_REPO="cloud-sdk-$(lsb_release -c -s)" && \
    echo "deb http://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && \
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        google-cloud-sdk=${GCLOUD_SDK_VERSION}-0 \
        google-cloud-sdk-app-engine-go=${GCLOUD_SDK_VERSION}-0 \
        google-cloud-sdk-datastore-emulator=${GCLOUD_SDK_VERSION}-0 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    chmod +x /usr/lib/google-cloud-sdk/platform/google_appengine/goapp /usr/lib/google-cloud-sdk/platform/google_appengine/appcfg.py

# setup go environment
ENV PATH=$PATH:/go/bin:/usr/local/go/bin
ENV GOPATH=/go
RUN curl -o go.tar.gz -L https://dl.google.com/go/go${GOLANG_VERSION}.linux-amd64.tar.gz && \
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
