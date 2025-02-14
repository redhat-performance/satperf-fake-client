ARG REGISTRY=registry.access.redhat.com
ARG TAG=latest

FROM ${REGISTRY}/ubi7/ubi-init:${TAG}

LABEL org.opencontainers.image.authors="Jan Hutar <jhutar@redhat.com>"

RUN INSTALL_PKGS="\
  less \
  openssh-server \
  subscription-manager \
  " \
  && echo -e "[repo1]\nname=repo1\nbaseurl=https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi/server/7/7Server/x86_64/os/\ngpgcheck=0\nenabled=1" >/etc/yum.repos.d/repo1.repo \
  && yum -y install $INSTALL_PKGS \
  && rpm -V --nosize --nofiledigest --nomtime --nomode $INSTALL_PKGS \
  && yum clean all

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

RUN rpm -qa | wc -l

WORKDIR /root

EXPOSE 22

CMD ["/sbin/init"]
