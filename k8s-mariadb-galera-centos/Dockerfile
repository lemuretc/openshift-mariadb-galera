FROM centos:7
MAINTAINER adfinis-sygroup.ch <info@adfinis-sygroup.ch>
#Date: Sun Jul 28 10:00:23 CEST 2019
LABEL io.k8s.description="MariaDB is a multi-user, multi-threaded SQL database server" \
      io.k8s.display-name="MariaDB 10.4" \
      io.openshift.expose-services="3306:mysql" \
      io.openshift.tags="database,mysql,mariadb10,rh-mariadb10"
EXPOSE 3306/tcp

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
