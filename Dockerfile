# Dockerfile References: https://docs.docker.com/engine/reference/builder/

# Start from the latest golang base image
FROM golang:latest as builder

# Add Maintainer Info
LABEL maintainer="ad1ee"

# Set the Current Working Directory inside the container
WORKDIR /app

# Copy go mod and sum files
COPY go.mod go.sum ./

# Download all dependencies. Dependencies will be cached if the go.mod and go.sum files are not changed
RUN go mod download

# Copy the source from the current directory to the Working Directory inside the container
COPY . .

# Build the Go app
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o main .

######## Start a new stage from scratch #######
FROM alpine:latest  

RUN apk --no-cache add ca-certificates

WORKDIR /root/

# Copy the Pre-built binary file from the previous stage
COPY --from=builder /app/main .

# Tentukan argumen untuk port
ARG PORT

# Set port sebagai environment variable
ENV PORT=${PORT}

# Tentukan port yang akan diekspos
EXPOSE ${PORT}

# Command to run the executable
CMD ["./main"] 