FROM java:8-jre
MAINTAINER "European Environment Agency (EEA): IDM2 A-Team" <eea-edw-a-team-alerts@googlegroups.com>

RUN apt-get update -q && \
    apt-get install wget netcat net-tools python3-pip pwgen --no-install-recommends -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    pip3 install chaperone

RUN mkdir -p /data /logs /conf /etc/chaperone.d

WORKDIR /opt

ENV GRAYLOG_VERSION="1.3.4"
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/jre
# Get graylog2 web and server and install into /opt/
ENV GRAYLOG_SERVER="graylog-$GRAYLOG_VERSION"
ENV GRAYLOG_WEB="graylog-web-interface-$GRAYLOG_VERSION"

RUN useradd -u 500 -s /bin/false -r -m graylog && \
    wget "http://packages.graylog2.org/releases/graylog2-server/$GRAYLOG_SERVER.tgz" -q && \
    tar -xf "$GRAYLOG_SERVER.tgz" && rm "$GRAYLOG_SERVER.tgz" && \
    mv "$GRAYLOG_SERVER" graylog2-server && \
    mkdir -p /etc/graylog/server/ && \
    cp graylog2-server/graylog.conf.example /etc/graylog/server/server.conf && \
    wget "http://packages.graylog2.org/releases/graylog2-web-interface/$GRAYLOG_WEB.tgz" -q && \
    tar -xf "$GRAYLOG_WEB.tgz" && rm "$GRAYLOG_WEB.tgz" && \
    mv "$GRAYLOG_WEB" graylog2-web-interface && \
    chown -R graylog /opt/graylog2-server /etc/graylog /opt/graylog2-web-interface

# Setup basic config
RUN sed -i -e "s/mongodb:\/\/localhost\/graylog2.*$/mongodb:\/\/mongodb.service\/graylog2/" /etc/graylog/server/server.conf && \
    sed -i -e "s/application.secret=.*$/application.secret=$(pwgen -s 96)/" /opt/graylog2-web-interface/conf/graylog-web-interface.conf && \
    sed -i -e "s/graylog2-server.uris=.*$/graylog2-server.uris=\"http:\/\/127.0.0.1:12900\/\"/" /opt/graylog2-web-interface/conf/graylog-web-interface.conf

EXPOSE 9000 12201/udp 12900

COPY chaperone.conf /etc/chaperone.d/chaperone.conf
COPY ./setup.sh setup.sh

USER graylog

ENTRYPOINT ["/usr/local/bin/chaperone"]
CMD []
