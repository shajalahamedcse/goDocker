## Motivation:

`Containers` are nothing but a complete software package that is bundled with all its dependencies, tools, libraries, runtime, configuration files, and anything else necessary to run the application.

Images are binary snapshots. Any kind of container is created from an image. This image contains everything needed to run the application. So when we run any instance of an image that is called container.

In this project , First we will try to build a docker image for a Golang application. Then we will try to attach a `docker volume`  with the container to store application logs. And in the final stage ,will do some optimization of this docker images using multistage docker build concept.

### Creating a Simple Golang App

Let's create a simple golang application that we'll containerize.

    $ mkdir -p $GOPATH/src/github.com/shajalahamedcse/godocker
    $ cd $GOPATH/src/github.com/callicoder/go-docker
    $ touch server.go

This will be a simple server that will just tell the health of the server. We wil use gorilla mux to create HTTP routes. It will listens for connections on port 8080. Let's write it now.

`server.go`

    package main

    import (
        "context"
        "fmt"
        "log"
        "net/http"
        "os"
        "os/signal"
        "syscall"
        "time"

        "github.com/gorilla/mux"
    )

    func main() {

        // Route handlers
        route := mux.NewRouter()

        route.HandleFunc("/", healthCheckHandler)
        // Create Server
        srv := &http.Server{
            Handler:      route,
            Addr:         ":8080",
            ReadTimeout:  10 * time.Second,
            WriteTimeout: 10 * time.Second,
        }

        // Start Server
        go func() {
            log.Println("Starting Server")
            if err := srv.ListenAndServe(); err != nil {
                log.Fatal(err)
            }
        }()

        // Graceful Shutdown
        waitForShutdown(srv)
    }

    func healthCheckHandler(w http.ResponseWriter, r *http.Request) {
        w.Write([]byte(fmt.Sprintf("It is working")))
    }

    func waitForShutdown(srv *http.Server) {
        interruptChan := make(chan os.Signal, 1)
        signal.Notify(interruptChan, os.Interrupt, syscall.SIGINT, syscall.SIGTERM)

        // Block until we receive our signal.
        <-interruptChan

        // Create a deadline to wait for.
        ctx, cancel := context.WithTimeout(context.Background(), time.Second*10)
        defer cancel()
        srv.Shutdown(ctx)

        log.Println("Shutting down")
        os.Exit(0)
    }


### Building and Running the server in your local environment

Let’s build and run our server locally.

    $ go build
    $ ./goDocker
    2018/12/22 19:33:54 Starting Server

### Dockerfile for Sever

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

    # Run the executable
    CMD ["goDocker"]
