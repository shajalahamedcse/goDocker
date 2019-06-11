## Motivation:

`Containers` are nothing but a complete software package that is bundled with all its dependencies, tools, libraries, runtime, configuration files, and anything else necessary to run the application.

Images are binary snapshots. Any kind of container is created from an image. This image contains everything needed to run the application. So when we run any instance of an image that is called container.

In this project , First I will try to build a docker image for a Golang application. Then I will try to attach a `docker volume`  with the container to store application logs. And in the final stage ,will do some optimization of this docker images using multistage docker build concept.

