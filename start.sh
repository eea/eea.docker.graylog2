#!/bin/bash
set -e

# Services starter for graylog2
cd /opt/

# Parse enabled services
if [ -z $ENABLED_SERVICES ]; then
    ENABLED_SERVICES="graylog-web,graylog-server,monit"
fi

for service in $(echo $ENABLED_SERVICES | sed 's/ //g' | sed 's/,/\n/g'); do
    if [ "elasticsearch" = $service ]; then
        ENABLE_ES="true"
    fi
    if [ "mongodb" = $service ]; then
        ENABLE_MONGO="true"
    fi
    if [ "graylog-web" = $service ]; then
        ENABLE_WEB="true"
    fi
    if [ "graylog-server" = $service ]; then
        ENABLE_SERVER="true"
    fi
    if [ "monit" = $service ]; then
        ENABLE_MONIT="true"
    fi
done

# Make data dirs
if ! [ -z $ENABLE_ES ]; then
    mkdir -p /data/elasticsearch
    mkdir -p /logs/elasticsearch
fi

if ! [ -z $ENABLE_MONGO ]; then
    mkdir -p /data/mongodb
    mkdir -p /logs/mongodb
fi

chmod -R 755 /data
chmod -R 755 /logs


if ! [ -z $ENABLE_ES ]; then
    chown -R elasticsearch:elasticsearch /data/elasticsearch
    chown -R elasticsearch:elasticsearch /logs/elasticsearch
fi
if ! [ -z $ENABLE_MONGO ]; then
    chown -R mongodb:mongodb /data/mongodb
    chown -R mongodb:mongodb /logs/mongodb
fi

# Override defaults if set in the /conf volume
if [ -f /conf/graylog-server.conf ]; then
    cp /conf/graylog-server.conf /etc/graylog/server/server.conf
    echo "Running with custom server conf"
fi
if [ -f /conf/graylog-web-interface.conf ]; then
    cp /conf/graylog-web-interface.conf /opt/graylog2-web-interface/conf/graylog-web-interface.conf
    echo "Running with custom web interface conf"
fi

# Start ES
if ! [ -z $ENABLE_ES ]; then
    echo -n "Starting elasticsearch... "
    sudo -H -u elasticsearch bash -c                \
        "/opt/elasticsearch/bin/elasticsearch       \
         -Des.path.data=/data/elasticsearch         \
         -Des.cluster.name=graylog2                 \
         -Des.path.logs=/logs/elasticsearch/        \
         -d"
    while ! echo exit | nc -z -w 3 localhost 9200;  do sleep 3; done
    echo "Started"
fi

# Start mongo
if ! [ -z $ENABLE_MONGO ]; then
    echo -n "Starting mongodb... "
    sudo -H -u mongodb bash -c                      \
        "/usr/bin/mongod                            \
         --dbpath=/data/mongodb                     \
         --smallfiles --quiet --logappend           \
         --logpath=/logs/mongodb/mongodb.log        \
         --fork &> /dev/null"
    while ! echo exit | nc -z -w 3 localhost 27017;  do sleep 3; done
    echo "Started"
fi

if ! [ -z $ENABLE_SERVER ]; then
    # Set an unusable password if none is set
    if [ -z $GRAYLOG_PASSWORD ] && \
       ! grep -q -E 'root_password_sha2 = .+' /etc/graylog/server/server.conf; then
        GRAYLOG_PASSWORD=$(pwgen -N 1 -s 96)
        echo "No password set, setting an unusable password"
    fi

    # Override password only if GRAYLOG_PASSWORD was set
    if ! [ -z $GRAYLOG_PASSWORD ]; then
        echo -n "Overriding password... "
        PASSWORD=$(echo -n "$GRAYLOG_PASSWORD" | sha256sum | awk '{print $1}')
        sed -i -e "s/root_password_sha2.*=.*$/root_password_sha2 = $PASSWORD/" /etc/graylog/server/server.conf
        # Reset env vars so no clear variable is available on the machine
        PASSWORD=""
        GRAYLOG_PASSWORD=""
        echo "Done"
    fi

    if ! [ -z $GRAYLOG_NODE_ID ]; then
        echo -n "Setting graylog node id... "
        ID_FILE=$(grep "node_id_file" /etc/graylog/server/server.conf | cut -d'=' -f2 | sed 's/[[:space:]]//g')
        echo $GRAYLOG_NODE_ID > $ID_FILE
        echo "Done"
    fi

    # Email transport configuration
    if ! [ -z $GRAYLOG_EMAIL_ENABLED ]; then
        echo -n "Enable mail transport... "
        sed -i -e "s/#transport_email_enabled.*=.*$/transport_email_enabled = $GRAYLOG_EMAIL_ENABLED/" /etc/graylog/server/server.conf
        # Reset env vars so no clear variable is available on the machine
        GRAYLOG_EMAIL_ENABLED=""
        echo "Done"
    fi
    if ! [ -z $GRAYLOG_EMAIL_HOSTNAME ]; then
        echo -n "Set email hostname... "
        sed -i -e "s/#transport_email_hostname.*=.*$/transport_email_hostname = $GRAYLOG_EMAIL_HOSTNAME/" /etc/graylog/server/server.conf
        # Reset env vars so no clear variable is available on the machine
        GRAYLOG_EMAIL_HOSTNAME=""
        echo "Done"
    fi
    if ! [ -z $GRAYLOG_EMAIL_PORT ]; then
        echo -n "Set email port... "
        sed -i -e "s/#transport_email_port.*=.*$/transport_email_port = $GRAYLOG_EMAIL_PORT/" /etc/graylog/server/server.conf
        # Reset env vars so no clear variable is available on the machine
        GRAYLOG_EMAIL_PORT=""
        echo "Done"
    fi
    if ! [ -z $GRAYLOG_EMAIL_USEAUTH ]; then
        echo -n "Set email use auth... "
        sed -i -e "s/#transport_email_use_auth.*=.*$/transport_email_use_auth = $GRAYLOG_EMAIL_USEAUTH/" /etc/graylog/server/server.conf
        # Reset env vars so no clear variable is available on the machine
        GRAYLOG_EMAIL_USEAUTH=""
        echo "Done"
    fi
    if ! [ -z $GRAYLOG_EMAIL_USETLS ]; then
        echo -n "Set email use tls... "
        sed -i -e "s/#transport_email_use_tls.*=.*$/transport_email_use_tls = $GRAYLOG_EMAIL_USETLS/" /etc/graylog/server/server.conf
        # Reset env vars so no clear variable is available on the machine
        GRAYLOG_EMAIL_USETLS=""
        echo "Done"
    fi
    if ! [ -z $GRAYLOG_EMAIL_USESSL ]; then
        echo -n "Set email use ssl... "
        sed -i -e "s/#transport_email_use_ssl.*=.*$/transport_email_use_ssl = $GRAYLOG_EMAIL_USESSL/" /etc/graylog/server/server.conf
        # Reset env vars so no clear variable is available on the machine
        GRAYLOG_EMAIL_USESSL=""
        echo "Done"
    fi
    if ! [ -z $GRAYLOG_EMAIL_AUTHUSERNAME ]; then
        echo -n "Set email auth username... "
        sed -i -e "s/#transport_email_auth_username.*=.*$/transport_email_auth_username = $GRAYLOG_EMAIL_AUTHUSERNAME/" /etc/graylog/server/server.conf
        # Reset env vars so no clear variable is available on the machine
        GRAYLOG_EMAIL_AUTHUSERNAME=""
        echo "Done"
    fi
    if ! [ -z $GRAYLOG_EMAIL_AUTHPSW ]; then
        echo -n "Set email auth password... "
        sed -i -e "s/#transport_email_auth_password.*=.*$/transport_email_auth_password = $GRAYLOG_EMAIL_AUTHPSW/" /etc/graylog/server/server.conf
        # Reset env vars so no clear variable is available on the machine
        GRAYLOG_EMAIL_AUTHPSW=""
        echo "Done"
    fi
    if ! [ -z $GRAYLOG_EMAIL_SUBJECT_PREFIX ]; then
        echo -n "Set email subject prefix... "
        sed -i -e "s/#transport_email_subject_prefix.*=.*$/transport_email_subject_prefix = $GRAYLOG_EMAIL_SUBJECT_PREFIX/" /etc/graylog/server/server.conf
        # Reset env vars so no clear variable is available on the machine
        GRAYLOG_EMAIL_SUBJECT_PREFIX=""
        echo "Done"
    fi
    if ! [ -z $GRAYLOG_EMAIL_FROM_EMAIL ]; then
        echo -n "Set email from email... "
        sed -i -e "s/#transport_email_from_email.*=.*$/transport_email_from_email = $GRAYLOG_EMAIL_FROM_EMAIL/" /etc/graylog/server/server.conf
        # Reset env vars so no clear variable is available on the machine
        GRAYLOG_EMAIL_FROM_EMAIL=""
        echo "Done"
    fi
    if ! [ -z $GRAYLOG_EMAIL_WEB_URL ]; then
        echo -n "Set email web url... "
        sed -i -e "s|#transport_email_web_interface_url.*=.*$|transport_email_web_interface_url = $GRAYLOG_EMAIL_WEB_URL|" /etc/graylog/server/server.conf
        # Reset env vars so no clear variable is available on the machine
        GRAYLOG_EMAIL_WEB_URL=""
        echo "Done"
    fi
    # end email transport configuration

    # Start graylog2 server
    /opt/graylog2-server/bin/graylogctl start

    echo -n "Waiting for server to be up and running... "
    while ! graylog2-server/bin/graylogctl status | grep -q "graylog-server running with PID"; do sleep 3; done
    while ! echo exit | nc -z -w 3 localhost 12900;  do sleep 3; done
    # Extra sleep for making the interface not yield an error
    echo "Started"
fi

# Start monit
if ! [ -z $ENABLE_MONIT ]; then
     sh -c "monit -c /etc/monit/monitrc"
fi


# Start graylog2 web interface and leave this as main output
if ! [ -z $ENABLE_WEB ]; then
    /opt/graylog2-web-interface/bin/graylog-web-interface
fi

echo "Started all required services"

# Fallback console logging
tail -f /dev/null


