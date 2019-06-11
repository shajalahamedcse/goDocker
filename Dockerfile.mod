# Start from golang v1.11 base image
FROM golang:1.11

# Add Maintainer Info
LABEL maintainer="shajalahamedcse@gmail.com"

# Set the Current Working Directory inside the container
WORKDIR $GOPATH/src/github.com/shajalahamedcse/go-docker

# Copy everything from the current directory to the PWD(Present Working Directory) inside the container
COPY . .

# Enable Go Modules
ENV GO111MODULE=on

# Build the Go app
RUN go build -o ./out/goDocker .

# This container exposes port 8080 to the outside world
EXPOSE 8080

# Run the binary program produced by `go install`
CMD ["./out/goDocker"]