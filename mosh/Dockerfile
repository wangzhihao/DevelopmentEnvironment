FROM ubuntu:latest

RUN  apt-get update && \
	apt-get install -y \
	mosh \
	netcat \
	locales 
RUN locale-gen en_US.UTF-8 

EXPOSE 60001/udp
ENTRYPOINT ["mosh-server"]

