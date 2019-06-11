## Motivation:

`Containers` are nothing but a complete software package that is bundled with all its dependencies, tools, libraries, runtime, configuration files, and anything else necessary to run the application.

Images are binary snapshots. Any kind of container is created from an image. This image contains everything needed to run the application. So when we run any instance of an image that is called container.

In this project , First we will try to build a docker image for a Golang application. Then we will try to attach a `docker volume`  with the container to store application logs. And in the final stage ,will do some optimization of this docker images using multistage docker build concept.

### Creating a Simple Golang App

Let's create a simple golang application that we'll containerize.

    $ mkdir -p $GOPATH/src/github.com/shajalahamedcse/godocker
    $ cd $GOPATH/src/github.com/callicoder/go-docker
    $ touch server.go

This will be a simple server that will just tell the health of the server. Let's write it now.
