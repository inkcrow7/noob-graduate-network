FROM golang:alpine as builder

RUN go env -w CGO_ENABLED=0

WORKDIR /build

COPY . .

RUN go build -gcflags=-trimpath=$GOPATH -asmflags=-trimpath=$GOPATH -ldflags '-extldflags "-static" -s -w' -o runner

FROM alpine:latest

RUN apk update && \
    apk upgrade --no-cache && \
    apk add --no-cache tzdata && \
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo 'Asia/Shanghai' >/etc/timezone && \
    rm -rf /var/cache/apk/*

COPY --from=builder /build/runner /usr/bin/runner
RUN chmod +x /usr/bin/runner

WORKDIR /data

ENTRYPOINT [ "/usr/bin/runner" ]
