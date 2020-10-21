FROM alpine:3.12

RUN apk add go

RUN apk --update upgrade \
    && apk --no-cache add git mercurial bash gcc musl-dev curl tar ca-certificates tzdata \
    && update-ca-certificates \
    && rm -rf /var/cache/apk/*

# Which docker version to test on
ARG DOCKER_VERSION=18.09.7

# Download docker
RUN apk add docker-cli

# Download go-bindata binary to bin folder in $GOPATH
RUN mkdir -p /usr/local/bin \
    && curl -fsSL -o /usr/local/bin/go-bindata https://github.com/containous/go-bindata/releases/download/v1.0.0/go-bindata \
    && chmod +x /usr/local/bin/go-bindata

# Download golangci-lint binary to bin folder in $GOPATH
RUN curl -sfL https://install.goreleaser.com/github.com/golangci/golangci-lint.sh | bash -s -- -b $GOPATH/bin v1.31.0

# Download misspell binary to bin folder in $GOPATH
RUN  curl -sfL https://raw.githubusercontent.com/client9/misspell/master/install-misspell.sh | bash -s -- -b $GOPATH/bin v0.3.4

# Download goreleaser binary to bin folder in $GOPATH
RUN curl -sfL https://install.goreleaser.com/github.com/goreleaser/goreleaser.sh | sh

WORKDIR /go/src/github.com/traefik/traefik

# Download go modules
COPY go.mod .
COPY go.sum .
RUN GO111MODULE=on GOPROXY=https://proxy.golang.org go mod download

COPY . /go/src/github.com/traefik/traefik
