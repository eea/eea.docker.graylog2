FROM java:openjdk-7-jre
MAINTAINER Luca Pisani <luca.pisani@abstract.it>

RUN apt-get update -q && \
    apt-get upgrade -y libc6 && \ 
    apt-get install wget netcat python3-pip pwgen --no-install-recommends -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    pip3 install chaperone

RUN mkdir -p /data /logs /conf /etc/chaperone.d

WORKDIR /opt

ENV GRAYLOG_VERSION="1.3.2"

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

RUN cp graylog2-server/graylog.conf.example /etc/graylog/server/server.conf
RUN useradd -u 500 -s /bin/false -r -m graylog && \
    chown -R graylog /opt/graylog2-server /opt/graylog2-web-interface /etc/graylog

# Setup basic config    
RUN sed -i -e "s/password_secret =.*$/password_secret = $(pwgen -s 96)/" /etc/graylog/server/server.conf
RUN sed -i -e "s/mongodb:\/\/localhost\/graylog2.*$/mongodb:\/\/mongodb.service\/graylog2/" /etc/graylog/server/server.conf
RUN sed -i -e "s/application.secret=.*$/application.secret=$(pwgen -s 96)/" /opt/graylog2-web-interface/conf/graylog-web-interface.conf
RUN sed -i -e "s/graylog2-server.uris=.*$/graylog2-server.uris=\"http:\/\/127.0.0.1:12900\/\"/" /opt/graylog2-web-interface/conf/graylog-web-interface.conf

EXPOSE 9000 12201/udp 12900 2812

COPY chaperone.conf /etc/chaperone.d/chaperone.conf
COPY ./setup.sh setup.sh

USER graylog

ENTRYPOINT ["/usr/local/bin/chaperone"]
CMD []
