FROM rhel9-ubi-init-smallest

LABEL org.opencontainers.image.authors="Pablo Mendez Hernandez <pablomh@redhat.com>"

ARG CLIENT_REPO_BASE=http://mirror.example.com

RUN echo -e "[satellite_client]\nname=Satellite_Client_RHEL9_x86_64\nbaseurl=${CLIENT_REPO_BASE}/Satellite_Client_RHEL9_x86_64/\ngpgcheck=0\nenabled=1" >/etc/yum.repos.d/satellite_client.repo && \
  dnf install -y foreman_ygg_worker && \
  dnf clean all

WORKDIR /root

EXPOSE 22

CMD ["/sbin/init"]
