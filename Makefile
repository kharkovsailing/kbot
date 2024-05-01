APP := $(shell basename $(shell git remote get-url origin))
REGISTRY := kharkovsailing
VERSION=$(shell git describe --tags --abbrev=0)-$(shell git rev-parse --short HEAD)
.DEFAULT_GOAL := build

TARGETOS=
TARGETARCH=

build_linux: TARGETOS=linux
build_linux: TARGETARCH=arm64
build_linux: build

linux: TARGETOS=linux
linux: TARGETARCH=arm64
linux: build

windows: TARGETOS=windows
windows: TARGETARCH=amd64
windows: build

macOS: TARGETOS=darwin
macOS: TARGETARCH=amd64
macOS: build_macOS

macOSARM: TARGETOS=darwin
macOSARM: TARGETARCH=arm64
macOSARM: build_macOSARM


format:
	gofmt -s -w ./

lint:
	golint

test:
	go test -v

get:
	go get

build: format get
	CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -v -o kbot -ldflags "-X="github.com/kharkovsailing/kbot/cmd.appVersion=${VERSION}

image:
	docker build . -t ${REGISTRY}/${APP}:${VERSION}-${TARGETARCH}  --build-arg TARGETARCH=${TARGETARCH}

push:
	docker push ${REGISTRY}/${APP}:${VERSION}-${TARGETARCH}

clean:
	rm -rf kbot
	docker rmi ${REGISTRY}/${APP}:${VERSION}-${TARGETARCH}
