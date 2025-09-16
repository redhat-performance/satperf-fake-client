ARG REGISTRY=registry.access.redhat.com
ARG TAG=latest

FROM ${REGISTRY}/ubi10/ubi-init:${TAG}

LABEL org.opencontainers.image.authors="Pablo Mendez Hernandez <pablomh@redhat.com>"

ARG INSTALL_PKGS="\
  containers-common \
  fuse-overlayfs \
  hostname \
  iputils \
  less \
  openssh-server \
  "

RUN dnf install -y ${INSTALL_PKGS} && \
  rpm -V --nosize --nofiledigest --nomtime --nomode ${INSTALL_PKGS} && \
  dnf clean all

RUN echo 'root:1:65535' >/etc/subuid && \
    echo 'root:1:65535' >/etc/subgid

ARG CONTAINER_RUNTIME=crun

COPY src/containers.conf.${CONTAINER_RUNTIME} /etc/containers/containers.conf

RUN chmod 644 /etc/containers/containers.conf

# Copy & modify the defaults to provide reference if runtime changes needed.
# Changes here are required for running with fuse-overlay storage inside container.
RUN sed \
  -e 's|^#mount_program|mount_program|g' \
  -e '/additionalimage.*/a "/var/lib/shared",' \
  -e 's|^mountopt[[:space:]]*=.*$|mountopt = "nodev,fsync=0"|g' \
  /usr/share/containers/storage.conf \
  >/etc/containers/storage.conf

# Note VOLUME options must always happen after the chown call above
# RUN commands can not modify existing volumes
VOLUME /var/lib/containers

RUN mkdir -p /var/lib/shared/overlay-images \
             /var/lib/shared/overlay-layers \
             /var/lib/shared/vfs-images \
             /var/lib/shared/vfs-layers && \
    touch /var/lib/shared/overlay-images/images.lock \
          /var/lib/shared/overlay-layers/layers.lock \
          /var/lib/shared/vfs-images/images.lock \
          /var/lib/shared/vfs-layers/layers.lock

ARG ROOT_PASSWORD
ARG ROOT_PUBLIC_KEY

RUN echo 'PermitRootLogin yes' >/etc/ssh/sshd_config.d/01-local.conf && \
  if [[ -n "${ROOT_PUBLIC_KEY}" ]]; then \
    mkdir -m 700 /root/.ssh && \
    install -m 600 /dev/null /root/.ssh/authorized_keys && \
    echo "${ROOT_PUBLIC_KEY}" >/root/.ssh/authorized_keys; \
  fi && \
  if [[ -n "${ROOT_PASSWORD}" ]]; then \
    echo "root:${ROOT_PASSWORD}" | chpasswd; \
  fi && \
  systemctl enable sshd.service

RUN dnf list installed | wc -l

RUN sed -i.orig \
  's#\(def in_container()\)\(.*:\)#\1\2\n    return False#g' \
  /usr/lib64/python*/*-packages/rhsm/config.py

WORKDIR /root

EXPOSE 22

CMD ["/sbin/init"]
