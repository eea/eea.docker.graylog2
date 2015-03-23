# All-in-one, ready to run Graylog2 Docker image

Out of the box, ready to run Graylog2 image.

Fit for open-source apps and configs.

Can run without specifying an admin password.

## Versions:
* latest: Graylog2 1.0.0
* 1.0.0: Graylog2 1.0.0

## Basic configuration
### Simple run:
```
docker run -e GRAYLOG_PASSWORD=password -p 9000:9000 eeacms/graylog2
```
Go to ```localhost:9000``` and log in using the __user:__ _admin_ and the __password:__ _password_
to check that graylog is running.

### Making the data persistent:
To reduce the risk of adding zombie volumes, the default image stores the data
inside the container. To make it persistent between runs or image upgrades you
can do one of the following:

* Mount a host volume inside the container:

```
docker run -v /path/to/your/data:/data -e GRAYLOG_PASSWORD=password -p 9000:9000 eeacms/graylog2
```

/data/mongodb contains mongodb data

/data/elasticsearch contains elasticsearch data

* Use a data-only container.
  If you don't want to impact the host's filesystem structure and use a
  container-only solution, you can use a data-only container.

First, create a container having a /data volume and give it an easy to remember
name:
```
docker run -v /data --name graylog2data ubuntu true
```

Then, mount the volumes defined in graylog2data using the --volumes-from
option.

```
docker run --volumes-from graylog2data -e GRAYLOG_PASSWORD=password -p 9000:9000 eeacms/graylog2
```

### Running with an unusable admin password
If you don't want to version your admin password in a ```docker-compose``` file
just log into ```localhost:9000``` after running the above command and setup your user or LDAP.
Then, re-run the image without the GRAYLOG_PASSWORD environment variable.

__Note__: The password salt is regenerated after each image build. If you added
an user and upgraded the image, the user's credentials will be unusable.
Follow [these steps](#config) to keep a consistent password salt between image updates.

```
docker run -v /path/to/your/data:/data -p 9000:9000 eeacms/graylog2
```

### Keeping node configuration persistent:
Graylog2 stores node config in a key: value manner, where the key is the node's id.
When using docker, the node id is given by the container id wich is regenerated after
each run. To have a persistent node_id use this:
```
docker run -v /path/to/your/data:/data -p 9000:9000 -e GRAYLOG_NODE_ID=node1 eeacms/graylog2
```

### Running on a multi-node setup(beta)

First, specify your configs locally as specified in the Useful Directories
section.

Then, enable only the services that you want to run via the ```ENABLED_SERVICES```
environment variable as specified in the Environment Variables section

## Ports

* 9000 - Graylog2 web interface
* 12900 - Graylog2 server API
* 12201 - GELF input

## Useful Directories

These directories can be added as volumes in order to have a better control
over the behavior of Graylog2.

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
  
# Contributing

If you used this image and saw something that can be improved, please send a Pull Request.
