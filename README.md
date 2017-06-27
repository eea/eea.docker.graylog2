# Standalone Graylog2 Docker image

Out of the box, ready to run Graylog2 image.

Fit for open-source apps and configs.

Can run without specifying an admin password.

## Versions:
* latest: Graylog2 2.2.3
* 2.2-3.0 Graylog2 2.2.3
* 2.0.3: Graylog2 2.0.3
* 2.0.2: Graylog2 2.0.2
* 1.3.4: Graylog2 1.3.4
* 1.3.3: Graylog2 1.3.3
* 1.3.2: Graylog2 1.3.2
* 1.2.2: Graylog2 1.2.2
* 1.2.1-2: Graylog2 1.2.1 with email transport configuration
* 1.2.1-1: Graylog2 1.2.1 standalone
* 1.2.1: Graylog2 1.2.1 allinone
* 1.0.0: Graylog2 1.0.0

## Dependencies

* ElasticSearch - [https://www.elastic.co](https://www.elastic.co)
* MongoDB - [https://www.mongodb.org](https://www.mongodb.org)

For a quick configuration example view [eea.docker.logcentral](https://github.com/eea/eea.docker.logcentral/blob/master/docker-compose.singlenode.yml)

## Ports

* 9000 - Graylog2 web interface
* 12900 - Graylog2 server API (DEPRECATED, API is now at :9000/api)
* 12201 - GELF input

## Configuration
Every configuration option can be set via environment variables, take a look [here](https://github.com/Graylog2/graylog2-server/blob/master/misc/graylog.conf) for an overview. Simply prefix the parameter name with ```GRAYLOG_``` and put it all in upper case. Another option would be to store the configuration file outside of the container and edit it directly.

## Environment variables

* ```GRAYLOG_PASSWORD``` - run the container overriding the admin password with
  the value of this parameter. If no password is set either via ```/config``` or
  this parameter, the server will run with an unusable auto-generated password.

* ```ENABLED_SERVICES``` - a list of comma separated values of the services to
  be ran in this container. The available services are: ```server```, ```web```. By default __all__
  services are started.

  __Note:__ This option works only with custom server or
  web interface configs because the default config expects elastic and mongo to be on localhost.

### Email transport configuration

* ```GRAYLOG_TRANSPORT_EMAIL_ENABLED``` - run the container with transport mail enable.

  __Note:__ the value of this parameter is ```true``` or ```false```

* ```GRAYLOG_TRANSPORT_EMAIL_HOSTNAME``` - the hostname of mail server.

* ```GRAYLOG_TRANSPORT_EMAIL_PORT``` - the port of mail server.

* ```GRAYLOG_TRANSPORT_EMAIL_USE_AUTH``` - set ```true``` if mail server use authentication, ```false``` otherwise.

  __Note:__ the value of this parameter is ```true``` or ```false```

* ```GRAYLOG_TRANSPORT_EMAIL_USE_TLS``` - set ```true``` if mail server use TLS authentication, ```false``` otherwise.

  __Note:__ the value of this parameter is ```true``` or ```false```

* ```GRAYLOG_TRANSPORT_EMAIL_USE_SSL``` - set ```true``` if mail server use SSL authentication, ```false``` otherwise.

  __Note:__ the value of this parameter is ```true``` or ```false```

* ```GRAYLOG_TRANSPORT_EMAIL_AUTH_USERNAME``` - the username used to connect to mail server if it use authentication.

* ```GRAYLOG_TRANSPORT_EMAIL_AUTH_PASSWORD``` - the password used to connect to mail server if it use authentication.

* ```GRAYLOG_TRANSPORT_EMAIL_SUBJECT_PREFIX``` - the subject prefix of sended emails.

* ```GRAYLOG_TRANSPORT_EMAIL_FROM_EMAIL``` - the sender email.

* ```GRAYLOG_TRANSPORT_EMAIL_WEB_INTERFACE_URL``` - the graylog2 web url used if you want to include links to the stream in your stream alert mails.
This should define the fully qualified base url to your web interface exactly the same way as it is accessed by your users.

#### Keeping node configuration persistent:
Graylog2 stores node config in a key: value manner, where the key is the node's id.
When using docker, the node id is given by the container id wich is regenerated after
each run. To have a persistent node_id use this:

```
docker run --name some-mongo -d mongo
docker run --name some-elasticsearch -d elasticsearch elasticsearch -Des.cluster.name="graylog2"
docker run -v /path/to/your/data:/data -p 9000:9000 12900:12900 eeacms/graylog2
```

### Useful Directories

These directories can be added as volumes in order to have a better control
over the behavior of Graylog2.

#### /config

```/config``` Can be added in order to use custom configuration files.
For the config to be loaded you have to add the following files:
* graylog-server.conf: For the graylog-server service
* graylog-web-interface.conf: For the graylog-web-interface service

If a file is not present, the service will run with the default configuration
(single container, all services available on localhost)

# Contributing

If you used this image and saw something that can be improved, please send a Pull Request.
