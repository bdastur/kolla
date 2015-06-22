FROM fedora:20
MAINTAINER Kolla Project (https://launchpad.net/kolla)

# Add Repo
ADD ./logstash-forwarder.repo /etc/yum.repos.d/logstash-forwarder.repo

# Set up repositories
RUN yum install -y wget
RUN yum install -y logstash-forwarder

# Expose Required Volumes
VOLUME [ "/var/log/rabbitmq" ]
VOLUME [ "/var/log/mariadb" ]
VOLUME [ "/var/log/haproxy" ]
VOLUME [ "/var/log/keystone" ]
VOLUME [ "/var/log/glance" ]
VOLUME [ "/var/log/neutron" ]
VOLUME [ "/var/log/nova" ]
VOLUME [ "/var/log/httpd" ]
VOLUME [ "/var/log/cinder" ]

# Add start-up script
ADD ./start.sh /start.sh
ADD ./logstash-forwarder.conf /logstash-forwarder.conf

CMD ["/start.sh"]
