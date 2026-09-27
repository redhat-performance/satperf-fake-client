FROM rhel8-ubi-init-smallest

LABEL org.opencontainers.image.authors="Pablo Mendez Hernandez <pablomh@redhat.com>"

RUN dnf install -y insights-client && \
  dnf clean all

ARG SATCLIENT_REPO_BASE=http://mirror.example.com
ARG SATCLIENT_PATH=Satellite_Client_RHEL8_x86_64

RUN echo -e "[satellite_client]\nname=${SATCLIENT_PATH}\nbaseurl=${SATCLIENT_REPO_BASE}/${SATCLIENT_PATH}/\ngpgcheck=0\nenabled=1" >/etc/yum.repos.d/satellite_client.repo && \
  dnf install -y foreman_ygg_worker && \
  dnf clean all

WORKDIR /root

EXPOSE 22

CMD ["/sbin/init"]
