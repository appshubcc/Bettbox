# Use multi-stage build to produce a small final image

FROM golang:1.21-alpine AS builder
WORKDIR /src
COPY . .
RUN go build -o /app/server ./server

FROM alpine:3.18
RUN apk add --no-cache ca-certificates
COPY --from=builder /app/server /usr/local/bin/server
EXPOSE 8080
ENTRYPOINT ["/usr/local/bin/server"]
