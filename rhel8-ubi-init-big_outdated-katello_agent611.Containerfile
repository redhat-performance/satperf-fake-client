FROM rhel8-ubi-init-big_outdated

MAINTAINER Jan Hutar <jhutar@redhat.com>

RUN echo -e "[satellite_client]\nname=satellite_client\nbaseurl=http://dogfood.sat.engineering.redhat.com/pulp/repos/Sat6-CI/QA/Satellite_6_11_with_RHEL8_Server/custom/Satellite_Client_Composes/Satellite_Client_RHEL8_x86_64/\ngpgcheck=0\nenabled=1" >/etc/yum.repos.d/satellite_client.repo \
    && dnf -y install katello-agent \
    && dnf clean all

WORKDIR /root

EXPOSE 22

CMD ["/sbin/init"]
