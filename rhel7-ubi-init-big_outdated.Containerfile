FROM rhel7-ubi-init-smallest

MAINTAINER Jan Hutar <jhutar@redhat.com>

RUN count=$( rpm -qa | wc -l | cut -d ' ' -f 1 ) \
    && target=$( expr 1000 - $count - 1 ) \
    && if [ -z "$target" -o "$target" -lt 1 ]; then echo "Bad target number of packages: $target" 1>&2; exit 1; fi \
    && pkgs=$( for i in $( seq 0 $( expr $target / 2 ) ); do echo -n " fakepkg$i fakepkg$i-sub0"; done ) \
    && echo -e "[fakepkgs]\nname=fakepkgs\nbaseurl=https://jhutar.fedorapeople.org/fakepkgs/el7/\ngpgcheck=0\nenabled=1" >/etc/yum.repos.d/fakepkgs.repo \
    && yum -y install $pkgs \
    && yum clean all

RUN rpm -qa | wc -l

WORKDIR /root

EXPOSE 22

CMD ["/sbin/init"]
