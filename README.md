jubaql-on-docker
================

JubaQL is a query language for [Jubatus](http://jubat.us/en/), a distributed processing framework and streaming machine learning library. The JubaQL Server allows to use data in a local file system, in HDFS or from an [Apache Kafka](http://kafka.apache.org/) message queue. Because it is rather complicated to set up HDFS and/or Kafka, this [Docker](https://www.docker.com/) environment is provided to get started quickly with JubaQL. It uses [fig](http://www.fig.sh/) for container orchestration.

These files are only meant for demonstration purposes and to document build steps and some necessary configuration settings. They are *not* meant to be used in a production environment.

## What does this Docker environment contain?

* *zookeeper* provides the Zookeeper functionality for Kafka.
* *kafka* provides a message queue that can be used for stream processing.
