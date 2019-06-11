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


### Using Go Modules for dependency management

If you’re using Go 1.11+, then you can use Go Modules for managing dependencies. Go Modules are enabled by default outside $GOPATH. But if your project is inside $GOPATH then you need to manually enable it by setting the following environment variable -

    # Activate Go modules inside $GOPATH (Add this to your ~/.bash_profile or ~/.bashrc file)
    export GO111MODULE=on


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


### Building and Running the Docker image


Now that we have written the Dockerfile , let’s build and run the docker image -

#### Building the image

    $ docker build -t godocker .

We can list all the available images we built by typing the following command -

    $ docker image ls


#### Running the Docker image

We can run the docker image using following command

    $ docker run -d -p 8080:8080 godocker

#### Finding Running containers

    $ docker container ls

#### Interacting with the server running inside the container

    $ curl http://localhost:8080
    It is working

#### Stopping the container

    $ docker container stop <CONTAINER ID>


### Attaching Volume to the Docker Container

Let’s write another Dockerfile. It will attach a volume to the container that will be used to store all the logs generated by the server we wrote. 



In the following Dockerfile, we declare a volume at path ` /goDocker/logs `. The container writes log files to `/goDocker/logs/server.log`. When we are running the image, we can easily mount a directory of the Host OS to this volume. Once we do that, we’ll be able to access all the log files from the mounted directory of the Host OS.


#### Dockerfile.volume

    # Use golang v1.11 as a base image
    FROM golang:1.11

    # Add maintainer info
    LABEL maintainer="shajalahamedcse@gmail.com"

    # Build Args
    ARG APP_NAME=goDocker
    ARG LOG_DIR=/${APP_NAME}/logs

    # Create Log Directory
    RUN mkdir -p ${LOG_DIR}

    # Environment Variables
    ENV LOG_FILE_LOCATION=${LOG_DIR}/server.log 

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

    # Declare volumes to mount
    VOLUME ["/goDocker/logs"]

    # Run the executable
    CMD ["goDocker"]


Let's build the image

    $ docker build -t godockervolume -f Dockerfile.volume .

Now if we have to run the image. Notice that how we mount a directory of the Host OS to the volume specified by the docker container 

    $ mkdir ~/serverLogs
    $ docker run -d -p 8080:8080 -v ~/serverLogs:/goDocker/logs godockervolume


We can now access our application’s logs from the ~/serverLogs directory 
    $ cd ~/serverLogs
    $ tail -200f server.log