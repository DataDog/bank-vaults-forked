ARG BASE_IMAGE
# See
# https://docs.docker.com/engine/reference/builder/#automatic-platform-args-in-the-global-scope
# for info on BUILDPLATFORM, TARGETOS, TARGETARCH, etc.
FROM --platform=$BUILDPLATFORM golang:1.22.2 AS builder
WORKDIR /go/src/github.com/bank-vaults
ENV CGO_ENABLED=1
COPY go.* .
ARG GOPROXY
RUN go mod download
COPY . .
ARG TARGETOS
ARG TARGETARCH
RUN GOOS=$TARGETOS GOARCH=$TARGETARCH go build -o /go/src/github.com/bank-vaults ./cmd/bank-vaults/
RUN GOOS=$TARGETOS GOARCH=$TARGETARCH go build -o /go/src/github.com/template ./cmd/template/

FROM $BASE_IMAGE
COPY --from=builder /go/src/github.com/bank-vaults /bin/bank-vaults
COPY --from=builder /go/src/github.com/template /bin/template
COPY --from=builder /go/src/github.com/bank-vaults/scripts/pcscd-entrypoint.sh /bin/pcscd-entrypoint.sh
ENTRYPOINT ["/bin/bank-vaults/bank-vaults"]
