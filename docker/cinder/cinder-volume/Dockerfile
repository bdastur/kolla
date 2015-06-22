FROM %%KOLLA_NAMESPACE%%/%%KOLLA_PREFIX%%base
MAINTAINER Kolla Project (https://launchpad.net/kolla)

COPY ./start.sh ./start.sh
COPY ./config-cinder.sh /opt/kolla/config-cinder.sh

CMD ["/start.sh"]
