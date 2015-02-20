FROM phusion/baseimage:0.9.16

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

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
  git sbt oracle-java7-installer wget

# add Spark distribution
RUN cd /usr/local && \
  wget http://d3kbcqa49mib13.cloudfront.net/spark-1.1.1-bin-hadoop2.4.tgz && \
  tar -xzf spark-1.1.1-bin-hadoop2.4.tgz
ENV SPARK_DIST /usr/local/spark-1.1.1-bin-hadoop2.4/

# download and build JubaQL client
WORKDIR /root
RUN git clone -b v1.2.0 https://github.com/jubatus/jubaql-client.git
RUN cd jubaql-client/ && sbt start-script

# download and build JubaQL server
RUN git clone -b v1.2.0 https://github.com/jubatus/jubaql-server.git
RUN cd jubaql-server/gateway/ && sbt assembly
COPY conf/ /root/jubaql-server/processor/src/main/resources
RUN cd jubaql-server/processor/ && sbt assembly

# install jubaql-gateway run script
COPY jubaql-gateway/ /etc/service/jubaql-gateway/
# install jubaql-client alias
COPY jubaql /usr/local/bin/
