FROM rhel10-ubi-init-smallest

LABEL org.opencontainers.image.authors="Pablo Mendez Hernandez <pablomh@redhat.com>"

ARG REPO_BASE=http://mirror.example.com

RUN echo -e "[rhel-10-beta-for-x86_64-appstream-rpms]\nname=Red Hat Enterprise Linux 10 Beta for x86_64 - AppStream\nbaseurl=${REPO_BASE}/rhel-10/nightly/RHEL-10/latest-RHEL-10.0/compose/AppStream/x86_64/os/\ngpgcheck=0\nenabled=1" >/etc/yum.repos.d/satellite_client.repo && \
  dnf install -y insights-client yggdrasil && \
  dnf clean all

ARG CLIENT_REPO_BASE=http://mirror.example.com

RUN echo -e "[satellite_client]\nname=Satellite_Client_RHEL10_x86_64\nbaseurl=${CLIENT_REPO_BASE}/Satellite_Client_RHEL10_x86_64/\ngpgcheck=0\nenabled=1" >/etc/yum.repos.d/satellite_client.repo && \
  dnf install -y foreman_ygg_worker && \
  dnf clean all

WORKDIR /root

EXPOSE 22

CMD ["/sbin/init"]
