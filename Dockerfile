FROM dockerfile/java:openjdk-7-jre
MAINTAINER Mihai Bivol <mihai.bivol@eaudeweb.ro>

RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10
RUN echo 'deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen' > /etc/apt/sources.list.d/mongodb.list
RUN apt-get update -q
RUN apt-get install wget -y

VOLUME ["/data"]
VOLUME ["/logs"]
VOLUME ["/conf"]

WORKDIR /opt

ENV GRAYLOG_VERSION="1.0.0"
ENV ES_VERSION="1.4.4"

# Get mongo
RUN apt-get install mongodb-org-server -y
RUN apt-get install pwgen -y

# Get elasticsearch
RUN wget "https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-$ES_VERSION.tar.gz" -q
RUN tar -xf "elasticsearch-$ES_VERSION.tar.gz" && rm "elasticsearch-$ES_VERSION.tar.gz"
RUN mv "elasticsearch-$ES_VERSION" elasticsearch
RUN useradd -s /bin/false -r -M elasticsearch

# Get graylog2 web and server and install into /opt/
ENV GRAYLOG_SERVER="graylog-$GRAYLOG_VERSION"
ENV GRAYLOG_WEB="graylog-web-interface-$GRAYLOG_VERSION"

RUN wget "http://packages.graylog2.org/releases/graylog2-server/$GRAYLOG_SERVER.tgz" -q
RUN wget "http://packages.graylog2.org/releases/graylog2-web-interface/$GRAYLOG_WEB.tgz" -q
RUN tar -xf "$GRAYLOG_SERVER.tgz" && rm "$GRAYLOG_SERVER.tgz"
RUN tar -xf "$GRAYLOG_WEB.tgz"    && rm "$GRAYLOG_WEB.tgz"
RUN mv "$GRAYLOG_SERVER" graylog2-server
RUN mv "$GRAYLOG_WEB" graylog2-web-interface
RUN mkdir -p /etc/graylog/server/

RUN useradd -s /bin/false -r -M graylog2
RUN chown graylog2:root /opt/graylog2-server /opt/graylog2-web-interface

# Setup basic config
RUN cp graylog2-server/graylog.conf.example /etc/graylog/server/server.conf
RUN sed -i -e "s/password_secret =.*$/password_secret = $(pwgen -s 96)/" /etc/graylog/server/server.conf
RUN sed -i -e "s/application.secret=.*$/application.secret=$(pwgen -s 96)/" /opt/graylog2-web-interface/conf/graylog-web-interface.conf
RUN sed -i -e "s/graylog2-server.uris=.*$/graylog2-server.uris=\"http:\/\/127.0.0.1:12900\/\"/" /opt/graylog2-web-interface/conf/graylog-web-interface.conf

EXPOSE 9000 12201/udp 12900

COPY ./start.sh start.sh
CMD /opt/start.sh

