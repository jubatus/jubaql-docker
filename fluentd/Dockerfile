# extend a working fluentd image
FROM jplock/fluentd:1.1.20

# install fluentd plugins to create dummy data and adding timestamps
RUN apt-get update
RUN apt-get install make
RUN /usr/lib/fluent/ruby/bin/fluent-gem install fluent-plugin-dummydata-producer
RUN /usr/lib/fluent/ruby/bin/fluent-gem install fluent-plugin-record-reformer

# add configuration files
COPY td-agent.conf /etc/td-agent/td-agent.conf
COPY conf/* /etc/td-agent/config.d/
