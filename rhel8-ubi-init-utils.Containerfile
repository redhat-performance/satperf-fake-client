FROM rhel8-ubi-init-smallest

MAINTAINER Jan Hutar <jhutar@redhat.com>

RUN INSTALL_PKGS="\
  iproute iputils openssh-clients \
  " \
  && dnf -y install $INSTALL_PKGS \
  && rpm -V --nosize --nofiledigest --nomtime --nomode $INSTALL_PKGS \
  && dnf clean all

WORKDIR /root

EXPOSE 22

CMD ["/sbin/init"]
