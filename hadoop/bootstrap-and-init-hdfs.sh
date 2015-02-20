#!/bin/bash

# start Hadoop and give it some time to start up
. /etc/bootstrap.sh
sleep 2
cd $HADOOP_PREFIX

# leave safe mode (which is entered because desired replication level
# cannot be reached)
bin/hadoop dfsadmin -safemode leave
# copy the JubatusOnYARN files to the required location
bin/hadoop fs -copyFromLocal /root/JubatusOnYarn/jubatusonyarn/jubatus-on-yarn /

# create directory structure for fluentd output
bin/hadoop fs -mkdir /user/fluentd
bin/hadoop fs -chown td-agent /user/fluentd
bin/hadoop fs -mkdir /user/empty
bin/hadoop fs -chown td-agent /user/empty
echo "HDFS set up correctly"

# main loop
while true
do
  # TODO make this signal-interruptible
  sleep 10
  echo "HDFS contents at `date`:"
  bin/hadoop fs -ls -R /user/fluentd
done
