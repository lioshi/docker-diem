FROM ubuntu:trusty
MAINTAINER lioshi <lioshi@lioshi.com>

# Install packages
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update 
RUN apt-get -y install supervisor git apache2 libapache2-mod-php5 mysql-server php5-mysql pwgen php5-mcrypt php5-intl php5-imap

RUN echo "# Include vhost conf" >> /etc/apache2/apache2.conf 
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf 
RUN echo "IncludeOptional /data/conf/*.conf" >> /etc/apache2/apache2.conf 
RUN echo "<Directory /data/www> " >> /etc/apache2/apache2.conf 
RUN echo "    Options Indexes FollowSymLinks Includes ExecCGI" >> /etc/apache2/apache2.conf 
RUN echo "    AllowOverride None" >> /etc/apache2/apache2.conf 
RUN echo "    Require all granted" >> /etc/apache2/apache2.conf 
RUN echo "</Directory>" >> /etc/apache2/apache2.conf 

# Timezone settings
ENV TIMEZONE="Europe/Paris"
RUN echo "date.timezone = '${TIMEZONE}'" >> /etc/php5/cli/php.ini && \
  echo "${TIMEZONE}" > /etc/timezone && sudo dpkg-reconfigure --frontend noninteractive tzdata

# Add image configuration and scripts
ADD start-apache2.sh /start-apache2.sh
ADD start-mysqld.sh /start-mysqld.sh
ADD run.sh /run.sh
RUN chmod 755 /*.sh
ADD my.cnf /etc/mysql/conf.d/my.cnf
ADD supervisord-apache2.conf /etc/supervisor/conf.d/supervisord-apache2.conf
ADD supervisord-mysqld.conf /etc/supervisor/conf.d/supervisord-mysqld.conf

# Remove pre-installed database
RUN rm -rf /var/lib/mysql/*

# Add MySQL utils
ADD create_mysql_admin_user.sh /create_mysql_admin_user.sh
RUN chmod 755 /*.sh

# config Apache
RUN a2enmod rewrite

# Environment variables to configure php
ENV PHP_UPLOAD_MAX_FILESIZE 10M
ENV PHP_POST_MAX_SIZE 10M

# Add volumes for MySQL 
VOLUME  ["/etc/mysql", "/var/lib/mysql" ]
# Add volumes for sites, confs and libs
# /data/conf : apache conf file
# /data/www  : site's file
# /data/lib  : external libs
VOLUME  ["/data"]

EXPOSE 80 3306
CMD ["/run.sh"]
