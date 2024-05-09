ARG TAG=latest

FROM registry.access.redhat.com/ubi7/ubi-init:${TAG}

MAINTAINER Jan Hutar <jhutar@redhat.com>

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

RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config \
  && mkdir /root/.ssh \
  && chmod 700 /root/.ssh \
  && touch /root/.ssh/authorized_keys \
  && chmod 600 /root/.ssh/authorized_keys \
  && if [ -n "${ROOT_PUBLIC_KEY}" ]; then echo "${ROOT_PUBLIC_KEY}" >>/root/.ssh/authorized_keys; fi \
  && if [ -n "${ROOT_PASSWORD}" ]; then echo "root:${ROOT_PASSWORD}" | chpasswd; fi \
  && systemctl enable sshd.service \
  && exit 0

RUN rpm -qa | wc -l

WORKDIR /root

EXPOSE 22

CMD ["/sbin/init"]
