# DevelopmentEnvironment

My Docker Development Environment. The image is registered in docker hub repository [wangzhihao/dev](https://hub.docker.com/r/wangzhihao/dev).


# Build 

Command "docker run -e xxx" won't take effects for RUN clause in dockerfile since
RUN clause happens in build time before image is generated and the command happens
after the images is generated. So we can only use ARG instead ENV.

Auto-built on docker hub has been turned off since the build ARG needs to know my machine's UID/GID.
We want the container user is the same as the host user.
See [this post](
https://medium.com/@mccode/understanding-how-uid-and-gid-work-in-docker-containers-c37a01d01cf)
for more explaination of UID/GID in docker:

```sh
docker build --build-arg UID=$UID --build-arg GID=$GID --build-arg UNAME=$USER -t wangzhihao/dev .
# or
docker build --no-cache --build-arg UID=$UID --build-arg GID=$GID --build-arg UNAME=$USER -t wangzhihao/dev .
```

# Run

```
docker run -d -t -i --network host \
   -v /workspace:/workspace \
   -v /home/zhihaow/.ssh:/home/zhihaow/.ssh \
   -v /home/zhihaow/.aws:/home/zhihaow/.aws \
   -v /home/zhihaow/brazil-pkg-cache:/home/zhihaow/brazil-pkg-cache \
   wangzhihao/dev
```
