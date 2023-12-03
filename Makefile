APP := $(shell basename $(shell git remote get-url origin))
REGISTRY := us-central1-docker.pkg.dev
PROJECT_ID := k8s-labs-406913
REPO := kbot
VERSION=$(shell git describe --tags --abbrev=0)-$(shell git rev-parse --short HEAD)

ARGS1 := $(word 1,$(MAKECMDGOALS))
ARGS2 := $(word 2,$(MAKECMDGOALS))
TARGETOS ?= $(if $(filter apple,$(ARGS1)),darwin,$(if $(filter windows,$(ARGS1)),windows,linux))
TARGETARCH ?= $(if $(filter arm arm64,$(ARGS2)),arm64,$(if $(filter amd amd64,$(ARGS2)),amd64,amd64))

format:
	gofmt -s -w ./

lint:
	golint

test:
	go test -v

get:
	go get

build: format get
	CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -v -o kbot${EXT} -ldflags "-X="github.com/corefey/kbot/cmd.appVersion=${VERSION}

linux: build

apple: build

windows: EXT = .exe
windows: build

image:
	docker build . -t ${REGISTRY}/${PROJECT_ID}/${REPO}/${APP}:${VERSION}-${TARGETARCH}  --build-arg TARGETARCH=${TARGETARCH}

push:
	docker push ${REGISTRY}/${PROJECT_ID}/${REPO}/${APP}:${VERSION}-${TARGETARCH}

clean:
	rm -rf kbot
	docker rmi ${REGISTRY}/${PROJECT_ID}/${REPO}/${APP}:${VERSION}-${TARGETARCH}

%::
	@true