# All-in-one Graylog2 Docker image

## Basic configuration
Basic run:
```
docker run -e GRAYLOG_PASSWORD=password eeacms/graylog2
```

Making the data persistent:
```
docker run -v /path/to/your/data:/data eeacms/graylog2
```

Forwarding the web interface port:
```
docker run -p 9000:9000 eeacms/graylog2
```

## Ports

* 9000 - graylog2 web interface
* 12900 - graylog2 server API
* 12201 - GELF input

## Volumes

### /config

```/config``` Can be added in order to use custom configuration files.
For the config to be loaded you have to add the following files:
* graylog-server.conf: For the graylog-server service
* graylog-web-interface.conf: For the graylog-web-interface service

If a file is not present, the service will run with the default configuration
(single container, all services available on localhost)

### /logs

```/logs``` Contains the elasticsearch and mongodb logs.

### /data

```/data``` contains elasticsearch and mongodb data so configs and stored logs are
persistent between container restarts.


# Environment variables

* ```GRAYLOG_PASSWORD``` - run the container overriding the admin password with
  the value of this parameter. If no password is set either via ```/config``` or
  this parameter, the server will run with an unusable auto-generated password.

* ```GRAYLOG_NODE_ID``` - run the container setting the node id to the given
  value.

  __Note:__ Use this parameter when you want to make non-global inputs persistent.

* ```ENABLED_SERVICES```(beta) - a list of comma separated values of the services to
  be ran in this container. The available services are: ```elasticsearch```,
  ```mongodb```, ```graylog-server```, ```graylog-web```. By default __all__
  services are started.

  __Note:__ This option works only with custom server or
  web interface configs because the default config expects elastic and mongo to be on localhost.

  __Note:__ Mongo and ElasticSearch are not directly configurable
  so please use this option with at either ```graylog-server``` or ```graylog-web``` set.
