# Use golang v1.11 as a base image
FROM golang:1.11

# Add maintainer info
LABEL maintainer="shajalahamedcse@gmail.com"

# Set present working directory inside the container
WORKDIR $GOPATH/src/github.com/shajalahamedcse/goDocker

# Copy everything from host directory to the PWD(Present Working Directory) inside the container
COPY . .

# go [command] ./...
# Here ./ tells to start from the current folder, ... tells to go down recursively.
# Download all dependency for golang
RUN go get -d -v ./...

# Install the package
RUN go install -v ./...

# This container exposes port 8080 to the outside world
EXPOSE 8080

# Run the binary program produced by `go install`
CMD ["goDocker"]
