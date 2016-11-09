FROM centos:6
ENV GIT="https://github.com/tukiyo/mysql4.0php5.3/releases/download/sources"

RUN \
  yum install -y -q \
    gcc gcc-c++ glibc ncurses-devel make rpm-build wget tar git \
  && yum clean all \
  && install -d /root/rpmbuild/SPECS /root/rpmbuild/SOURCES

WORKDIR /root/rpmbuild/SOURCES

#---------
# mysql
#---------
RUN \
  wget -q "$GIT/mysql-4.0.30.tar.gz" \
  && tar xzf mysql-4.0.30.tar.gz \
  && rm -f mysql-4.0.30.tar.gz

WORKDIR /root/rpmbuild/SOURCES/mysql-4.0.30
RUN \
  ./configure --prefix=/opt/mysql --with-charset=ujis --with-extra-charsets=sjis --quiet \
  && make -s \
  && make install

RUN \
  yum install -y -q gettext \
  && rpm -ivh "$GIT/checkinstall-20150420-1.x86_64.rpm" \
  && ln -s /usr/local/lib/installwatch.so /usr/local/lib64/installwatch.so \
  && checkinstall -y -R --pkgname=opt-mysql4 \
  && ls -lh /root/rpmbuild/RPMS/x86_64/*.rpm

#----------
# local-php
#----------
WORKDIR /root/rpmbuild/SOURCES
RUN wget -q "${GIT}/php-5.3.3-47.el6.src.rpm"
RUN yum install -y -q yum-utils \
  && yum-builddep -y -q php-5.3.3-47.el6.src.rpm

# get php source
RUN wget -q "${GIT}/php-5.3.29.tar.gz"
RUN tar xzf php-5.3.29.tar.gz
WORKDIR /root/rpmbuild/SOURCES/php-5.3.29
## configure need mysql4.0
#RUN yum install -y -q "https://github.com/tukiyo/mysql4.0php5.3/releases/download/2016-08/opt-mysql4-4.0.30-1.x86_64.rpm"
RUN yum install -y -q "/root/rpmbuild/RPMS/x86_64/opt-mysql4-4.0.30-1.x86_64.rpm"

RUN yum install -y -q lemon bison
## epel have libmcrypt-devel rec2c packages.
RUN rpm -ivh "${GIT}/epel-release-6-8.noarch.rpm"
RUN yum install -y -q libmcrypt-devel re2c
## configure
ENV CONFIGURE="--prefix=/usr/local/php --with-apxs2=/usr/sbin/apxs --with-pear=/usr/local/pear --disable-cgi --enable-mbstring --with-mysql=shared,/opt/mysql --with-openssl --with-mhash=shared,/usr --with-mcrypt=shared,/usr --enable-sockets --enable-pcntl --enable-sigchild --with-gd=shared --with-jpeg-dir=/usr --with-png-dir=/usr --with-zlib-dir=/usr --with-freetype-dir=/usr --enable-gd-native-ttf --enable-gd-jis-conv"
ENV CONFIGURE="$CONFIGURE --enable-zend-multibyte"
ENV CONFIGURE="$CONFIGURE --with-config-file-path=/etc/ --with-config-file-scan-dir=/etc/php.d"
RUN ./configure --quiet ${CONFIGURE}
RUN make -s
## httpdパッケージとconfrictするため /etc/httpd/conf/httpd.conf を除外
RUN make install
RUN checkinstall -y -R --pkgname=local-php --exclude=/etc/httpd/conf/ \
  && ls -lh /root/rpmbuild/RPMS/x86_64/*.rpm

#---------
# local-pear
#---------
RUN /usr/local/php/bin/pear install DB-1.8.2
RUN /usr/local/php/bin/pear install Var_Dump
WORKDIR /usr/local
RUN tar czf /root/rpmbuild/SOURCES/local-pear.tar.gz \
  pear php/bin/pear php/bin/peardev php/bin/gen_php_doc.sh
RUN tar xzf /root/rpmbuild/SOURCES/local-pear.tar.gz \
  -C /root/rpmbuild/BUILD/
WORKDIR /root/rpmbuild/
COPY local-pear.spec SPECS/
RUN rpmbuild -ba SPECS/local-pear.spec

#---------
# resuilt
#---------
RUN sh -c "find . | grep \.rpm$ | xargs ls -lh"
