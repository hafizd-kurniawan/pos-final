FROM golang:1.21-alpine AS builder

WORKDIR /app

# Install dependencies
RUN apk add --no-cache git

# Copy go mod files
COPY go.mod go.sum ./
RUN go mod download

# Copy source code
COPY . .

# Build the application
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o main cmd/server/main.go

# Final stage
FROM alpine:latest

RUN apk --no-cache add ca-certificates tzdata
WORKDIR /root/

# Create necessary directories
RUN mkdir -p /app/static/uploads /app/templates

# Copy the binary
COPY --from=builder /app/main /app/main
COPY --from=builder /app/templates /app/templates

# Set working directory
WORKDIR /app

# Expose port
EXPOSE 8080

# Run the binary
CMD ["./main"]