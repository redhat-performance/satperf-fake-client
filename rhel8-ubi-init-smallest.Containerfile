ARG REGISTRY=registry.access.redhat.com
ARG TAG=latest

FROM ${REGISTRY}/ubi8/ubi-init:${TAG}

LABEL org.opencontainers.image.authors="Jan Hutar <jhutar@redhat.com>"

ARG INSTALL_PKGS="\
  containers-common \
  fuse-overlayfs \
  hostname \
  iproute \
  iputils \
  less \
  openssh-server \
  "

RUN dnf install -y ${INSTALL_PKGS} && \
  rpm -V --nosize --nofiledigest --nomtime --nomode ${INSTALL_PKGS} && \
  dnf clean all

RUN echo 'root:1:65535' >/etc/subuid && \
    echo 'root:1:65535' >/etc/subgid

ARG CONTAINER_RUNTIME=runc

COPY src/containers.conf.${CONTAINER_RUNTIME} /etc/containers/containers.conf

RUN chmod 644 /etc/containers/containers.conf

# Copy & modify the defaults to provide reference if runtime changes needed.
# Changes here are required for running with fuse-overlay storage inside container.
RUN sed -i.orig \
  -e 's|^#mount_program|mount_program|g' \
  -e '/additionalimage.*/a "/var/lib/shared",' \
  -e 's|^mountopt[[:space:]]*=.*$|mountopt = "nodev,fsync=0"|g' \
  /etc/containers/storage.conf

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

RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
  if [[ -n "${ROOT_PUBLIC_KEY}" ]]; then \
    mkdir -m 700 /root/.ssh && \
    install -m 600 /dev/null /root/.ssh/authorized_keys && \
    echo "${ROOT_PUBLIC_KEY}" >>/root/.ssh/authorized_keys; \
  fi && \
  if [[ -n "${ROOT_PASSWORD}" ]]; then \
    echo "root:${ROOT_PASSWORD}" | chpasswd; \
  fi && \
  systemctl enable sshd.service

RUN dnf list installed | wc -l

COPY src/renamer.service /etc/systemd/system/

RUN systemctl enable renamer.service

WORKDIR /root

EXPOSE 22

CMD ["/sbin/init"]
