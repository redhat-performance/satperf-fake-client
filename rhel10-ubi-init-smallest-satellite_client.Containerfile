FROM rhel10-ubi-init-smallest

LABEL org.opencontainers.image.authors="Pablo Mendez Hernandez <pablomh@redhat.com>"

ARG REPO_BASE=http://mirror.example.com
ARG REPO_PATH=
ARG RHEL_REL=
ARG DO_UPDATE=false

RUN if [ -n "${RHEL_REL}" ]; then \
      RHEL_MAJOR="${RHEL_REL%%.*}"; \
      echo -e "[rhel-${RHEL_MAJOR}-for-x86_64-baseos-rpms]\nname=Red Hat Enterprise Linux ${RHEL_MAJOR} for x86_64 - BaseOS\nbaseurl=${REPO_BASE}/${REPO_PATH}/BaseOS/x86_64/os/\ngpgcheck=0\nenabled=1" >/etc/yum.repos.d/RHEL.repo && \
      echo -e "[rhel-${RHEL_MAJOR}-for-x86_64-appstream-rpms]\nname=Red Hat Enterprise Linux ${RHEL_MAJOR} for x86_64 - AppStream\nbaseurl=${REPO_BASE}/${REPO_PATH}/AppStream/x86_64/os/\ngpgcheck=0\nenabled=1" >>/etc/yum.repos.d/RHEL.repo; \
    else \
      echo -e "[rhel-10-for-x86_64-appstream-rpms]\nname=Red Hat Enterprise Linux 10 for x86_64 - AppStream\nbaseurl=${REPO_BASE}/RHEL-10/10.0/AppStream/x86_64/os/\ngpgcheck=0\nenabled=1" >/etc/yum.repos.d/RHEL.repo; \
    fi && \
    if [ "${DO_UPDATE}" = "true" ]; then dnf update -y; fi && \
    dnf install -y insights-client subscription-manager yggdrasil && \
    dnf clean all

RUN sed -i.orig \
  's#\(def in_container()\)\(.*:\)#\1\2\n    return False#g' \
  /usr/lib64/python*/*-packages/rhsm/config.py

ARG RHSM_CERT_ALGORITHMS_CURRENT=false

RUN if [ "${RHSM_CERT_ALGORITHMS_CURRENT}" = "true" ]; then subscription-manager config --rhsm.certificate_algorithms=current; fi

ARG SATCLIENT_REPO_BASE=http://mirror.example.com
ARG SATCLIENT_PATH=Satellite_Client_RHEL10_x86_64

RUN echo -e "[satellite_client]\nname=${SATCLIENT_PATH}\nbaseurl=${SATCLIENT_REPO_BASE}/${SATCLIENT_PATH}/\ngpgcheck=0\nenabled=1" >/etc/yum.repos.d/satellite_client.repo && \
  dnf install -y foreman_ygg_worker && \
  dnf clean all

RUN rm -f /etc/yum.repos.d/*

WORKDIR /root

EXPOSE 22

CMD ["/sbin/init"]
