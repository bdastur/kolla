FROM fedora:20
MAINTAINER Kolla Project (https://launchpad.net/kolla)

RUN yum -y install \
    haproxy python-jinja2 \
    keepalived \
    rsyslog \
    && yum clean all

RUN mkdir -p /etc/haproxy/templates
ADD haproxy.cfg.tmpl /etc/haproxy/templates/haproxy.cfg.tmpl
ADD start.py /start.py
CMD ["/start.py"]

