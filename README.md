# Standalone Graylog2 Docker image

Out of the box, ready to run Graylog2 image.

Fit for open-source apps and configs.

Can run without specifying an admin password.

## Versions:
* latest: Graylog2 1.3.4
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

For a quick configuration example view [eea.docker.logcentral](https://github.com/eea/eea.docker.logcentral/blob/master/docker-compose.yml)

## Ports

* 9000 - Graylog2 web interface
* 12900 - Graylog2 server API
* 12201 - GELF input

## Environment variables

* ```GRAYLOG_HOSTNAME``` - the hostname to set into ```rest_listen_uri```. 
  __Note:__ Default value ```127.0.0.1```

* ```GRAYLOG_SECRET``` - You must set a secret that is used for password encryption
  end salting here. The server will refuse to start if it’s not set. Generate a 
  secret with for example pwgen -N 1 -s 96.
  If you not set this variable, a secret password will be generated for you.
  __Note:__ If you run multiple graylog-server nodes, make sure you use the same 
  ```password_secret``` for all of them!

* ```GRAYLOG_MASTER``` - Set only one graylog-server node as the master.
  This node will perform periodical and maintenance actions that slave nodes won’t.
  Every slave node will accept messages just as the master nodes. Nodes will fall
  back to slave mode if there already is a master in the cluster.
  ***Important*** Possible value is ```true``` or ```false```.


* ```GRAYLOG_PASSWORD``` - run the container overriding the admin password with
  the value of this parameter. If no password is set either via ```/config``` or
  this parameter, the server will run with an unusable auto-generated password.

* ```GRAYLOG_NODE_ID``` - run the container setting the node id to the given
  value.

  __Note:__ Use this parameter when you want to make non-global inputs persistent.

* ```ENABLED_SERVICES``` - a list of comma separated values of the services to
  be ran in this container. The available services are: ```elasticsearch```,
  ```mongodb```, ```graylog-server```, ```graylog-web```. By default __all__
  services are started.

  __Note:__ This option works only with custom server or
  web interface configs because the default config expects elastic and mongo to be on localhost.

  __Note:__ Mongo and ElasticSearch are not directly configurable
  so please use this option with at either ```graylog-server``` or ```graylog-web``` set.

* ```GRAYLOG_SERVER_URIS``` -  This is the list of graylog-server nodes the web 
  interface will try to use. You can configure one or multiple, separated by commas.
  Use the ```rest_listen_uri``` (configured in graylog.conf) of your graylog-server instances here.
  __Note:__ Default value ```http://localhost:12900/```

### Email transport configuration

* ```GRAYLOG_EMAIL_ENABLED``` - run the container with transport mail enable.

  __Note:__ the value of this parameter is ```true``` or ```false```

* ```GRAYLOG_EMAIL_HOSTNAME``` - the hostname of mail server.

* ```GRAYLOG_EMAIL_PORT``` - the port of mail server.

* ```GRAYLOG_EMAIL_USEAUTH``` - set ```true``` if mail server use authentication, ```false``` otherwise.

  __Note:__ the value of this parameter is ```true``` or ```false```

* ```GRAYLOG_EMAIL_USETLS``` - set ```true``` if mail server use TLS authentication, ```false``` otherwise.

  __Note:__ the value of this parameter is ```true``` or ```false```

* ```GRAYLOG_EMAIL_USESSL``` - set ```true``` if mail server use SSL authentication, ```false``` otherwise.

  __Note:__ the value of this parameter is ```true``` or ```false```

* ```GRAYLOG_EMAIL_AUTHUSERNAME``` - the username used to connect to mail server if it use authentication.

* ```GRAYLOG_EMAIL_AUTHPSW``` - the password used to connect to mail server if it use authentication.

* ```GRAYLOG_EMAIL_SUBJECT_PREFIX``` - the subject prefix of sended emails.

* ```GRAYLOG_EMAIL_FROM_EMAIL``` - the sender email.

* ```GRAYLOG_EMAIL_WEB_URL``` - the graylog2 web url used if you want to include links to the stream in your stream alert mails.
This should define the fully qualified base url to your web interface exactly the same way as it is accessed by your users.

#### Keeping node configuration persistent:
Graylog2 stores node config in a key: value manner, where the key is the node's id.
When using docker, the node id is given by the container id wich is regenerated after
each run. To have a persistent node_id use this:

```
docker run -v /path/to/your/data:/data -p 9000:9000 -e GRAYLOG_NODE_ID=node1 eeacms/graylog2
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

#### /logs

```/logs``` Contains the elasticsearch and mongodb logs.

#### /data

```/data``` contains elasticsearch and mongodb data so configs and stored logs are
persistent between container restarts.

# Contributing

If you used this image and saw something that can be improved, please send a Pull Request.
