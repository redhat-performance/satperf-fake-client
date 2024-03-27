FROM rhel9-ubi-init-smallest

MAINTAINER Pablo Mendez Hernandez <pablomh@redhat.com>

RUN count=$( dnf list installed | wc -l | cut -d ' ' -f 1 ) && \
  target=$( expr 1000 - $count - 1 ) && \
  if [ -z "$target" -o "$target" -lt 1 ]; then echo "Bad target number of packages: $target" 1>&2; exit 1; fi && \
  pkgs=$( for i in $( seq 0 $( expr $target / 2 ) ); do echo -n " fakepkg$i-0.1 fakepkg$i-sub0-0.1"; done ) && \
  echo -e "[fakepkgs]\nname=fakepkgs\nbaseurl=https://jhutar.fedorapeople.org/fakepkgs/el8/\ngpgcheck=0\nenabled=1" >/etc/yum.repos.d/fakepkgs.repo && \
  dnf -y install $pkgs && \
  dnf clean all

RUN dnf list installed | wc -l

WORKDIR /root

EXPOSE 22

CMD ["/sbin/init"]
