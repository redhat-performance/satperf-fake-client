FROM rhel9-ubi-init-big_outdated

MAINTAINER Pablo Mendez Hernandez <pmendezh@redhat.com>

RUN echo -e "[satellite_client]\nname=satellite_client\nbaseurl=http://satellite.sat.engineering.redhat.com/pulp/content/Satellite_Engineering/QA/Satellite_Client/custom/Satellite_Client_2_Composes/Satellite_Client_RHEL9_x86_64/\ngpgcheck=0\nenabled=1" >/etc/yum.repos.d/satellite_client.repo && \
  dnf install -y foreman_ygg_worker && \
  dnf clean all

WORKDIR /root

EXPOSE 22

CMD ["/sbin/init"]
