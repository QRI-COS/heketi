# set author and base
FROM alpine:3

ENV BUILD_HOME=/build
ENV GOPATH=$BUILD_HOME/golang
ENV PATH=$GOPATH/bin:$PATH
ENV HEKETI_REPO="https://github.com/heketi/heketi.git"
ENV HEKETI_BRANCH="master"
ENV GO111MODULE=off

RUN apk add --no-cache glide git make mercurial findutils bash && \
    mkdir $BUILD_HOME $GOPATH && \
    mkdir -p $GOPATH/src/github.com/heketi

WORKDIR $GOPATH/src/github.com/heketi

RUN git clone -b $HEKETI_BRANCH $HEKETI_REPO

WORKDIR $GOPATH/src/github.com/heketi/heketi 

RUN glide install -v && \
    make && \
    mkdir -p /etc/heketi /var/lib/heketi && \
    make install prefix=/usr && \
    cp /usr/share/heketi/container/heketi-start.sh /usr/bin/heketi-start.sh && \
    cp /usr/share/heketi/container/heketi.json /etc/heketi/heketi.json && \
    glide cc && \
    dos2unix /usr/bin/heketi-start.sh

WORKDIR /

RUN rm -rf $BUILD_HOME && \
    apk del git glide mercurial go

VOLUME /etc/heketi /var/lib/heketi

# expose port, set user and set entrypoint with config option
ENTRYPOINT ["/usr/bin/heketi-start.sh"]
EXPOSE 8080
