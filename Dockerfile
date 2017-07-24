FROM ubuntu:17.04
MAINTAINER vvakame <vvakame@gmail.com>

# GAE/Go build & testing environment for Circle CI 2.0

ENV GAE_VERSION 1.9.56
ENV GOLANG_VERSION 1.8.3
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
RUN curl -o go_appengine_sdk.zip https://storage.googleapis.com/appengine-sdks/featured/go_appengine_sdk_linux_amd64-${GAE_VERSION}.zip && \
    unzip go_appengine_sdk.zip && \
    rm go_appengine_sdk.zip

# setup go environment
ENV PATH=$PATH:/go/bin:/usr/local/go/bin
ENV GOPATH=/go
RUN curl -o go.tar.gz https://storage.googleapis.com/golang/go${GOLANG_VERSION}.linux-amd64.tar.gz && \
    tar -zxvf go.tar.gz && \
    mv go /usr/local && \
    rm go.tar.gz

# setup node.js environment
ENV PATH=/root/.nodebrew/current/bin:$PATH
RUN curl -L git.io/nodebrew | perl - setup && nodebrew install-binary ${NODEJS_VERSION} && nodebrew use ${NODEJS_VERSION}

# setup browser environment
RUN apt-get update && \
    apt-get install -y --no-install-recommends libappindicator1 && \
    curl --silent --show-error --location --fail --retry 3 -o google-chrome-stable_current_amd64.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
    (dpkg -i google-chrome-stable_current_amd64.deb || apt-get -fy install) && \
    rm -rf google-chrome-stable_current_amd64.deb && \
    sed -i 's|HERE/chrome"|HERE/chrome" --disable-setuid-sandbox --no-sandbox|g' /opt/google/chrome/google-chrome && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
