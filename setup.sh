#!/bin/bash

# Parse enabled services
if [ -z $ENABLED_SERVICES ]; then
    ENABLED_SERVICES="web,server"
fi

for service in $(echo $ENABLED_SERVICES | sed 's/ //g' | sed 's/,/\n/g'); do
    if [ "web" = $service ]; then
        ENABLE_WEB="true"
    fi
    if [ "server" = $service ]; then
        ENABLE_SERVER="true"
    fi
done

# Configure greylog options
if ! [ -z $ENABLE_SERVER ]; then

    # Clean up from previous executions (if any)
    rm -rf /var/run/*.pid /tmp/*.pid

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

fi

# Enable/Disable greylog web interface
if [ -z $ENABLE_WEB ]; then
   echo -n "Disable web interface... "
   sed -i -e "s/#web_enable.*=.*$/web_enable = false/" /etc/graylog/server/server.conf
fi
