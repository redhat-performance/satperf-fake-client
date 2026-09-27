FROM rhel9-ubi-init-smallest

LABEL org.opencontainers.image.authors="Pablo Mendez Hernandez <pablomh@redhat.com>"

ARG REPO_BASE=http://mirror.example.com

RUN echo -e "[rhel-9-for-x86_64-appstream-rpms]\nname=Red Hat Enterprise Linux 9 for x86_64 - AppStream\nbaseurl=${REPO_BASE}/RHEL-9/9.4.0/AppStream/x86_64/os/\ngpgcheck=0\nenabled=1" >/etc/yum.repos.d/RHEL.repo && \
  dnf install -y insights-client && \
  dnf clean all

ARG SATCLIENT_REPO_BASE=http://mirror.example.com
ARG SATCLIENT_PATH=Satellite_Client_RHEL9_x86_64

RUN echo -e "[satellite_client]\nname=${SATCLIENT_PATH}\nbaseurl=${SATCLIENT_REPO_BASE}/${SATCLIENT_PATH}/\ngpgcheck=0\nenabled=1" >/etc/yum.repos.d/satellite_client.repo && \
  dnf install -y foreman_ygg_worker && \
  dnf clean all

WORKDIR /root

EXPOSE 22

CMD ["/sbin/init"]
