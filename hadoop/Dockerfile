# extend a working hadoop image
FROM sequenceiq/hadoop-docker:2.6.0

# install Jubatus
RUN rpm -Uvh http://download.jubat.us/yum/rhel/6/stable/x86_64/jubatus-release-6-1.el6.x86_64.rpm
RUN yum install -y jubatus jubatus-client git

# TODO get JubatusOnYARN from the published zip files

# we need the Hadoop configuration files on the classpath for
# JubatusOnYARN to start Jubatus successfully
RUN echo "export CLASSPATH=/usr/local/hadoop/etc/hadoop/" > \
  /etc/profile.d/jubatusonyarnclasspath.sh

# put the YARN configuration (memory settings etc.) in place
COPY yarn-site.xml /usr/local/hadoop/etc/hadoop/

# add custom start script to create files and directories in HDFS
COPY bootstrap-and-init-hdfs.sh /etc/
CMD ["/etc/bootstrap-and-init-hdfs.sh"]
