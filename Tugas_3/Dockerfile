FROM ubuntu:16.04
RUN echo 'deb http://archive.ubuntu.com/ubuntu xenial universe' | tee -a /etc/apt/sources.list
RUN apt-get update
RUN apt-get install -y python python-virtualenv libmysqlclient-dev
RUN apt-get install -y git
RUN apt-get install -y python-dev
RUN apt-get install -y build-essential autoconf libtool pkg-config

RUN mkdir -p /usr/src/app
RUN virtualenv /usr/src/app/env
COPY ./reservasi /usr/src/app
RUN /usr/src/app/env/bin/pip install -r /usr/src/app/req.txt
ENTRYPOINT /usr/src/app/env/bin/python /usr/src/app/server.py
