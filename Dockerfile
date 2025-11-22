# Build stage
FROM golang:1.25.4-alpine AS builder
WORKDIR /app
COPY . .
RUN CGO_ENABLED=0 go build -ldflags "-w -extldflags \"-static\""  -o sender ./cmd/sender

# Final stage
FROM gcr.io/distroless/static
COPY --from=builder /app/sender /
ENTRYPOINT ["/sender"]
