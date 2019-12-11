FROM ubuntu:19.10
LABEL maintainer="vvakame@gmail.com"

# GAE/Go build & testing environment for Circle CI 2.0

ENV GCLOUD_SDK_VERSION 273.0.0
# same as google-cloud-sdk/platform/google_appengine/lib/grpcio-X.X.X
ENV PIP_GRPCIO_VERSION 1.20.0
ENV GOLANG_VERSION 1.11.13
ENV DEP_VERSION 0.5.4
ENV NODEJS_VERSION v12

RUN mkdir /work
WORKDIR /work

# for Cloud Datastore Emulator: openjdk-11-jre-headless python-pip
#   https://issuetracker.google.com/issues/119212211

RUN apt-get update && \
    ln -sf /usr/share/zoneinfo/UTC /etc/localtime && \
    apt-get install -y --no-install-recommends \
        tzdata xvfb vim \
        curl ca-certificates \
        build-essential git unzip \
        ssh \
        python \
        gettext-base \
        openjdk-11-jre-headless python-pip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# for Cloud Datastore Emulator: grpcio
RUN pip install grpcio==${PIP_GRPCIO_VERSION}

# setup Google Cloud SDK & GAE/Go Environment
ENV PATH=/work/google-cloud-sdk/bin:/work/google-cloud-sdk/platform/google_appengine:$PATH
RUN curl -o google-cloud-sdk.tar.gz https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-${GCLOUD_SDK_VERSION}-linux-x86_64.tar.gz && \
    tar -zxf google-cloud-sdk.tar.gz && \
    rm google-cloud-sdk.tar.gz && \
    ./google-cloud-sdk/install.sh --quiet && \
    gcloud --quiet components install app-engine-go && \
    chmod +x /work/google-cloud-sdk/platform/google_appengine/appcfg.py
# RUN gcloud --quiet components install cloud-datastore-emulator docker-credential-gcr kubectl alpha beta

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
