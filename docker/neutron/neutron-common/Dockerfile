FROM %%KOLLA_NAMESPACE%%/%%KOLLA_PREFIX%%neutron-base
MAINTAINER Kolla Project (https://launchpad.net/kolla)

#Install required packages
RUN yum install -y openstack-neutron \
        openstack-neutron-linuxbridge \
        python-neutronclient \
        openstack-neutron-linuxbridge \
        && yum clean all


VOLUME [ "/etc/neutron" ]


# Command needed to start the data container.
# Note: data containers do not need to be persistent.
CMD ["/bin/sh"]
