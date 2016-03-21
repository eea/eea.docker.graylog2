#!/bin/bash

# Parse enabled services
if [ -z $ENABLED_SERVICES ]; then
    ENABLED_SERVICES="graylog-web,graylog-server"
fi

for service in $(echo $ENABLED_SERVICES | sed 's/ //g' | sed 's/,/\n/g'); do
    if [ "graylog-web" = $service ]; then
        ENABLE_WEB="true"
    fi
    if [ "graylog-server" = $service ]; then
        ENABLE_SERVER="true"
    fi
done

# Configure greylog options
if ! [ -z $ENABLE_SERVER ]; then

    # Clean up from previous executions (if any)
    rm -rf /var/run/*.pid /tmp/*.pid

    # Override defaults if set in the /conf volume
    if [ -f /conf/graylog-server.conf ]; then
        cp /conf/graylog-server.conf /etc/graylog/server/server.conf
        echo "Running with custom server conf"
    fi

    # Set GRAYLOG_HOSTNAME
    if ! [ -z $GRAYLOG_HOSTNAME ]; then
        sed -i -e "s/rest_listen_uri.*=.*$/rest_listen_uri = http:\/\/$GRAYLOG_HOSTNAME:12900\//" /etc/graylog/server/server.conf
        echo "Hostname setted"
        GRAYLOG_HOSTNAME=""
    fi

    # Set GRAYLOG_SECRET
    if ! [ -z $GRAYLOG_SECRET ]; then
        sed -i -e "s/password_secret.*=.*$/password_secret = $GRAYLOG_SECRET/" /etc/graylog/server/server.conf
        echo "Secret password set using env var"
    else
        sed -i -e "s/password_secret.*=.*$/password_secret = $(pwgen -s 96)/" /etc/graylog/server/server.conf
        echo "Secret password generated and set"
        GRAYLOG_SECRET=""
    fi

    # Set GRAYLOG_MASTER
    if ! [ -z $GRAYLOG_MASTER ]; then
        sed -i -e "s/is_master.*=.*$/is_master = $GRAYLOG_MASTER/" /etc/graylog/server/server.conf
        echo "Master var set"
    fi

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
    
    # Set GRAYLOG_ELASTIC_REPLICA
    if ! [ -z $GRAYLOG_ELASTIC_REPLICA ]; then
        sed -i -e "s/#elasticsearch_discovery_zen_ping_multicast_enabled.*=.*$/elasticsearch_discovery_zen_ping_multicast_enabled = false/" /etc/graylog/server/server.conf
        safe_pattern=$(printf '%s\n' "$GRAYLOG_ELASTIC_REPLICA" | sed "s/[[\.*^$/]/\\&/g")
        sed -i -e "s/#elasticsearch_discovery_zen_ping_unicast_hosts.*=.*$/elasticsearch_discovery_zen_ping_unicast_hosts = \"${safe_pattern}\"/" /etc/graylog/server/server.conf
        echo "Set GRAYLOG_ELASTIC_REPLICA"
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
        safe_pattern=$(printf '%s\n' "$GRAYLOG_EMAIL_WEB_URL" | sed 's/[[\.*^$/]/\\&/g')
        sed -i -e "s/#transport_email_web_interface_url.*=.*$/transport_email_web_interface_url = ${safe_pattern}/" /etc/graylog/server/server.conf
        # Reset env vars so no clear variable is available on the machine
        GRAYLOG_EMAIL_WEB_URL=""
        echo "Done"
    fi
    # end email transport configuration

fi

if ! [ -z $ENABLE_WEB ]; then
    # Clean up from previous executions (if any)
    rm -rf /opt/graylog2-web-interface/RUNNING_PID

    # Override defaults if set in the /conf volume
    if [ -f /conf/graylog-web-interface.conf ]; then
        cp /conf/graylog-web-interface.conf /opt/graylog2-web-interface/conf/graylog-web-interface.conf
        echo "Running with custom web interface conf"
    fi

    # Set GRAYLOG_SERVER_URIS
    if ! [ -z $GRAYLOG_SERVER_URIS ]; then
        safe_pattern=$(printf '%s\n' "$GRAYLOG_SERVER_URIS" | sed 's/[[\.*^$/]/\\&/g')
        sed -i -e "s/graylog2-server.uris.*=.*$/graylog2-server.uris=\"${safe_pattern}\"/" /opt/graylog2-web-interface/conf/graylog-web-interface.conf
        echo "Set SERVER_URIS"
    else
        sed -i -e "s/graylog2-server.uris.*=.*$/graylog2-server.uris=\"http:\/\/localhost:12900\/\"/" /opt/graylog2-web-interface/conf/graylog-web-interface.conf
    fi
fi
