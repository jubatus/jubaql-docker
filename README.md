jubaql-on-docker
================

JubaQL is a query language for [Jubatus](http://jubat.us/en/), a distributed processing framework and streaming machine learning library. The JubaQL Server allows to use data in a local file system, in HDFS or from an [Apache Kafka](http://kafka.apache.org/) message queue. Because it is rather complicated to set up HDFS and/or Kafka, this [Docker](https://www.docker.com/) environment is provided to get started quickly with JubaQL. It uses [fig](http://www.fig.sh/) for container orchestration.

These files are only meant for demonstration purposes and to document build steps and some necessary configuration settings. They are *not* meant to be used in a production environment.

## What does this Docker environment contain?

There are a total of five containers:

* *zookeeper* provides the Zookeeper functionality for Kafka.
* *kafka* provides a message queue that can be used for stream processing.
* *hdpnode* is a single-container Hadoop cluster with YARN and HDFS. The JubaQL executors will run in this container, therefore it also contains a Jubatus installation.
* *fluentd* runs an instance of fluentd that generates dummy data with timestamps and writes it both to HDFS and Kafka.
* *jubaql* runs the JubaQL gateway as a daemon and provides the JubaQL client shell via the `jubaql` command.

## Get JubaQL running quickly

* Make sure you have Docker and fig installed and working and that you can use the [docker-bash](https://github.com/phusion/baseimage-docker/tree/rel-0.9.15#docker_bash) tool from the baseimage-docker distribution (0.9.15 or earlier) or have another way of entering a running container.
* Clone the repository and switch into the checked-out folder: `cd jubaql-docker/`
* Build the image files (this will take quite a while due to download and compilation):  
  `sudo fig build`
* Start up all containers:  
  `sudo fig up`
* In another shell, log in to the running *jubaql* container using  
  `sudo docker-bash jubaqldocker_jubaql_1`  
  start the JubaQL client using  
  `jubaql`  
  and you are ready to go.
* For example, you could run the following commands:
    * `CREATE CLASSIFIER MODEL ctr_predict (label: Click) AS Depth, Position, Tokens_query, Tokens_keyword, Tokens_title, Tokens_description, Gender, Age CONFIG '{"method": "AROW", "parameter": {"regularization_weight" : 1.0}}'`
    * `CREATE DATASOURCE kdd2012(Click string, Depth numeric, Position numeric, Tokens_query string, Tokens_keyword string, Tokens_title string, Tokens_description string, Gender string, Age numeric) FROM (STORAGE: "hdfs:///user/fluentd/kdddummy", STREAM: "kafka://zk:2181/kdddummy/1")`
    * `STATUS`  
      (This will show the status of the data source and the Jubatus instance.)
    * `UPDATE MODEL ctr_predict USING train FROM kdd2012`
    * `START PROCESSING kdd2012`  
      (Wait a couple of seconds after this statement.)
    * `ANALYZE '{"Gender":"female", "Impression":1, "DisplayURL":14340390157469404125, "AdId":6434954, "AdvertiserId":23777, "Depth":2, "Position":1, "Tokens_query":"", "Tokens_keyword":"", "Tokens_title":"", "Tokens_description":"", "Age":2}' BY MODEL ctr_predict USING classify`  
      (You should see output indicating how likely a person with the given properties will click on an ad banner.)
    * `STOP PROCESSING`
    * `SHUTDOWN`

## Troubleshooting

* In some Linux distributions (in particular Fedora), there may be [issues with selinux](https://github.com/sequenceiq/hadoop-docker/issues/14) in the Hadoop container. If the Hadoop container fails to start up or shows error messages, try to disable selinux.
* In this setup, a total of 7 GB RAM has been granted to YARN for resource management. You may or may not run into problems if your physical machine does not provide enough RAM. Consider to edit the file `hadoop/hadoopconf/yarn-site.xml` to tweak settings.
* It seems to happen with some version of fig that the *hdpnode* container is not linked properly to other containers because of slow startup. In this case, first do `fig up hdpnode` in one shell and after successful startup, run `fig up --no-deps jubaql fluentd` in a different shell.

## Using real data

It makes only limited sense to work with "real data" in this Docker-based environment, because it does not actually scale out and suffers from a certain overhead compared to running directly on your computer. However, it is possible to use non-dummy data as described below.

### HDFS, directly

* Enter the HDFS container: `sudo docker-bash jubaqldocker_hdpnode_1`.
* The executables for Hadoop are in `/usr/local/hadoop/bin`, so you can create a directory in HDFS using  
  `/usr/local/hadoop/bin/hadoop fs -mkdir /some/dir`  
  and then copy files there using  
  `/usr/local/hadoop/bin/hadoop fs -copyFromLocal /data /some/dir`
* This can then be used in a `CREATE DATASOURCE` statement as  
  `STORAGE: "/some/dir"`.  
  Note that the JubaQL server will skip all files with a modified timestamp within the last five minutes, assuming they may still be written to.

### HDFS via fluentd

* In the directory cloned via git, create a copy of `fluentd/conf/23_sink-hdfs-only.conf` in that same location and name it something like `99_sink-custom.conf`. Edit the file by changing the tag in the `<match>` clause and the HDFS `path` in the `<store>` section to your likings.
* Rebuild the container: `sudo fig build fluentd`.
* Restart the container: `sudo fig up --no-deps fluentd`.
* Enter the container: `sudo docker-bash jubaqldocker_fluentd_1`.
* Now you can pipe your data to fluentd using `fluent-cat <tag>` and it will end up in the HDFS directory you specified in your configuration file.  
  Note that the JubaQL server will skip all files with a modified timestamp within the last five minutes, assuming they may still be written to.

### HDFS and Kafka via fluentd

This approach gives you the full power of JubaQL's combined static + stream data processing. It allows to first process a historic archive of data and then seamlessly switch to current data. In order to do this seamless switch, we need a strictly increasing value in every data item, which will be added by a fluentd transformer.

* In the directory cloned via git, create a copy of `fluentd/conf/21_sink-dummy.conf` in that same location and name it something like `99_sink-custom.conf`. Edit the file by changing the tag in the `<match>` clause, the `path` in the HDFS `<store>` section, and the `default_topic` in the Kafka `<store>` section to your likings. Note that the tag to match must start with `jubaql.`, though. Let's assume it is `jubaql.xyz` for this manual.
* Rebuild the container: `sudo fig build fluentd`.
* Restart the container: `sudo fig up --no-deps fluentd`.
* Enter the container: `sudo docker-bash jubaqldocker_fluentd_1`.
* Now you can pipe your data to fluentd using `fluent-cat data.xyz` or any other supported method to get data into fluentd using the tag `data.xyz`. There is a transformer rule in place that will add the current time with the key `jubaql_timestamp` and change the tag to `jubaql.xyz`. Then the sink you created before will write that data to the specified HDFS path and Kafka topic. (Note that in this environment Kafka is configured to autocreate topics.)
