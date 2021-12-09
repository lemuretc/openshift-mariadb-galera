FROM centos:7
MAINTAINER lemuretc <lemuretc@gmail.com>

LABEL io.k8s.description="MariaDB is a multi-user, multi-threaded SQL database server" \
      io.k8s.display-name="MariaDB 10.5" \
      io.openshift.expose-services="3306:mysql" \
      io.openshift.tags="database,mysql,mariadb10,rh-mariadb10"
EXPOSE 3306/tcp
EXPOSE 4444/tcp
EXPOSE 4455/tcp
EXPOSE 4567/tcp
EXPOSE 4568/tcp
EXPOSE 4568/udp

COPY root/etc/yum.repos.d/mariadb.repo /etc/yum.repos.d/

RUN rpm --import https://yum.mariadb.org/RPM-GPG-KEY-MariaDB && \
    yum install -y \
      epel-release && \
    yum install -y \
      MariaDB-client \
      MariaDB-server \
      galera-4 \
      which \
      socat \
      MariaDB-backup \
      bind-utils \
      policycoreutils && \
	yum update -y && \
    yum clean all
RUN echo '!include /etc/config/my_extra.cnf' >> /etc/my.cnf

COPY root /
RUN /usr/libexec/container-setup.sh

VOLUME ["/var/lib/mysql"]
USER 27
ENTRYPOINT ["/usr/bin/container-entrypoint.sh"]
