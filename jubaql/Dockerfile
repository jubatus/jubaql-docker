FROM phusion/baseimage:0.9.16

# add 3rd party repositories: sbt, Java
RUN echo "deb http://dl.bintray.com/sbt/debian /" | \
  sudo tee -a /etc/apt/sources.list.d/sbt.list
RUN add-apt-repository ppa:webupd8team/java

# install packages
RUN apt-get update
# accept the Java license
RUN echo oracle-java7-installer shared/accepted-oracle-license-v1-1 \
  select true | /usr/bin/debconf-set-selections
RUN DEBIAN_FRONTEND=noninteractive apt-get -y --force-yes install \
  git sbt oracle-java7-installer

# add Spark distribution (the URL below has a Last-Modified header,
# so the file will not be downloaded again for every build)
ADD http://d3kbcqa49mib13.cloudfront.net/spark-1.1.1-bin-hadoop2.4.tgz \
  /usr/local/
RUN cd /usr/local && tar -xzf spark-1.1.1-bin-hadoop2.4.tgz
ENV SPARK_DIST /usr/local/spark-1.1.1-bin-hadoop2.4/

# TODO build JubaQL client and server from git

# install jubaql-gateway run script
COPY jubaql-gateway/ /etc/service/jubaql-gateway/
# install jubaql-client alias
COPY jubaql /usr/local/bin/

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

