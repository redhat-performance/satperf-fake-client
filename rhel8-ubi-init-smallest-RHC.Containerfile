FROM rhel8-ubi-init-smallest

MAINTAINER Jan Hutar <jhutar@redhat.com>

RUN dnf install -y rhc rhc-worker-playbook \
    && dnf clean all

WORKDIR /root

# Not needed for this container, but can be convenient
EXPOSE 22

CMD ["/sbin/init"]
