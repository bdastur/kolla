FROM %%KOLLA_NAMESPACE%%/%%KOLLA_PREFIX%%glance-base
MAINTAINER Kolla Project (https://launchpad.net/kolla)

VOLUME /var/lib/glance

ADD ./start.sh /start.sh
ADD ./check.sh /check.sh

CMD ["/start.sh"]
