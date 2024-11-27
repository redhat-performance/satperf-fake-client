ARG REGISTRY=registry.access.redhat.com
ARG TAG=latest

FROM ${REGISTRY}/rhel10-beta/rhel-bootc:${TAG}

LABEL org.opencontainers.image.authors="Pablo Mendez Hernandez <pablomh@redhat.com>"

ARG ROOT_PASSWORD
ARG ROOT_PUBLIC_KEY

RUN echo 'PermitRootLogin yes' >/etc/ssh/sshd_config.d/01-local.conf && \
  mkdir -pm 0700 /var/roothome && \
  if [[ -n "${ROOT_PUBLIC_KEY}" ]]; then \
    mkdir -m 700 /root/.ssh && \
    install -m 600 /dev/null /root/.ssh/authorized_keys && \
    echo "${ROOT_PUBLIC_KEY}" >/root/.ssh/authorized_keys; \
  fi && \
  if [[ -n "${ROOT_PASSWORD}" ]]; then \
    echo "root:${ROOT_PASSWORD}" | chpasswd; \
  fi && \
  systemctl enable sshd.service && \
  exit 0

RUN dnf list installed | wc -l

RUN sed -i.orig \
  's#\(def in_container()\)\(.*:\)#\1\2\n    return False#g' \
  /usr/lib64/python*/*-packages/rhsm/config.py

WORKDIR /root

EXPOSE 22

CMD ["/sbin/init"]
