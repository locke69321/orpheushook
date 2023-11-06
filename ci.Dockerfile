# build app
FROM --platform=$BUILDPLATFORM golang:1.20-alpine3.16 AS app-builder

RUN apk add --no-cache git tzdata

ENV SERVICE=orpheushook

WORKDIR /src
COPY . ./

RUN --mount=target=. \
    go mod download

ARG VERSION=dev
ARG REVISION=dev
ARG BUILDTIME
ARG TARGETOS TARGETARCH

RUN --mount=target=. \
    GOOS=$TARGETOS GOARCH=$TARGETARCH go build -ldflags "-s -w -X main.version=${VERSION} -X main.commit=${REVISION} -X main.date=${BUILDTIME}" -o /out/bin/orpheushook ./main.go
# build runner
FROM alpine:latest

LABEL org.opencontainers.image.source = "https://github.com/locke69321/orpheushook"

ENV HOME="/config" \
XDG_CONFIG_HOME="/config" \
XDG_DATA_HOME="/config"

RUN apk --no-cache add ca-certificates curl tzdata jq

WORKDIR /app
VOLUME /config
EXPOSE 7474
ENTRYPOINT ["/usr/local/bin/orpheushook"]

COPY --from=app-builder /out/bin/orpheushook /usr/local/bin/