FROM %%KOLLA_NAMESPACE%%/%%KOLLA_PREFIX%%nova-base
MAINTAINER Kolla Project (https://launchpad.net/kolla)

RUN yum -y install \
        openstack-nova-api && yum clean all

VOLUME [ "/etc/nova" ]


# Command needed to start the data container.
# Note: data containers do not need to be persistent.
CMD ["/bin/sh"]

