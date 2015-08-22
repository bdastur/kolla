FROM %%KOLLA_NAMESPACE%%/%%KOLLA_PREFIX%%base
MAINTAINER Kolla Project (https://launchpad.net/kolla)

# Install required packages
RUN yum -y install \
    memcached \
    nmap-ncat \
    && yum clean all



# Copy start-up script
COPY start.sh /

CMD ["/start.sh"]
