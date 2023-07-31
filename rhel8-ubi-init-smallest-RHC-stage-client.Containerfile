FROM rhel8-ubi-init-smallest

MAINTAINER Shubham Bansal <shubansa@redhat.com>

RUN dnf install -y rhc rhc-worker-playbook \
    && dnf clean all

WORKDIR /root

EXPOSE 22

CMD ["/sbin/init"]
