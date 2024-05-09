ARG TAG=latest

FROM registry.access.redhat.com/ubi8/ubi-init:${TAG}

MAINTAINER Jan Hutar <jhutar@redhat.com>

RUN INSTALL_PKGS="\
  hostname \
  iproute \
  iputils \
  less \
  openssh-server \
  " && \
  dnf install -y ${INSTALL_PKGS} && \
  rpm -V --nosize --nofiledigest --nomtime --nomode ${INSTALL_PKGS} && \
  dnf clean all

COPY src/renamer.service /etc/systemd/system/renamer.service

RUN systemctl enable renamer.service

ARG ROOT_PASSWORD
ARG ROOT_PUBLIC_KEY

RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
  if [[ -n "${ROOT_PUBLIC_KEY}" ]]; then \
    mkdir -m 700 /root/.ssh && \
    install -m 600 /dev/null /root/.ssh/authorized_keys && \
    echo "${ROOT_PUBLIC_KEY}" >>/root/.ssh/authorized_keys; \
  fi && \
  if [[ -n "${ROOT_PASSWORD}" ]]; then \
    echo "root:${ROOT_PASSWORD}" | chpasswd; \
  fi && \
  systemctl enable sshd.service && \
  exit 0

RUN dnf list installed | wc -l

WORKDIR /root

EXPOSE 22

CMD ["/sbin/init"]
