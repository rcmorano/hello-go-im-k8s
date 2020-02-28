FROM golang:1.14 as dev-env
# gin related env vars
ENV GIN_LADDR 0.0.0.0
ENV GIN_PORT 3001
ENV BIN_APP_PORT 3000

RUN go get -v github.com/codegangsta/gin
WORKDIR /go/src
COPY ./src app
COPY ./src/go.mod go.mod
COPY ./src/go.sum go.sum
RUN test -e go.mod || go mod init app && \
    go mod tidy
RUN go mod download
WORKDIR /go/src/app

RUN go build -o app api.go
CMD gin --immediate run api.go

FROM gcr.io/distroless/base as prod
ENV PORT 3000
COPY --from=dev-env /go/src /
CMD ["/app"]
