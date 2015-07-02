

Run services
	
	sudo docker run -d -p 80:80 -p 3306:3306 lioshi/docker-diem

Bash access

	sudo docker run -i -t lioshi/docker-diem bash



Pull an image

    service docker start
    service docker status

    sudo docker pull fedora:22

Delete a docker image

    sudo docker rmi -f f1b10cd84249

Delete all containers

    sudo docker rm $(sudo docker ps -a -q)

Delete all images

    sudo docker rmi $(sudo docker images -q)

Build an image
    
    sudo docker build --tag="docker-diem:latest" .


## Launch
Container launching
	
    sudo docker run -d -p 80:80 -p 3306:3306 -v /data:/data -e MYSQL_PASS="admin" --name=docker-diem docker-diem:latest

Command line access of previous container

    sudo docker exec -it docker-diem bash

## Apache2

See status
	
	apachectl status
	apachectl configtest


## Create Dockerfile in github

See https://github.com/lioshi/docker-diem

## Automatic build image

créer image: https://www.wanadev.fr/docker-vivre-avec-une-baleine-partie-2/
interactive build image : http://www.projectatomic.io/docs/docker-building-images/









###PHP dev

####Permissions
Se mettre en administrateur

**Désactiver SELinux**
SELinuwx ajoute une couche de sécurity plutôt ennuyeuse pour les accès apache, et autres... On la désactive donc...
La première est d'éditer le fichier /etc/selinux/config et de remplacer la ligne SELINUX=enforcing par:

    SELINUX=disabled

puis de rebooter le système.

####Apache

    dnf -y install httpd-manual;\
    service httpd start;\
    chkconfig httpd on;

####Ajout de l'arborescence de configuration www
    
    mkdir /data; \
    mkdir /data/conf; \
    mkdir /data/www; \
    mkdir /data/www/_lib; \
    chown -R lioshi:lioshi /data/; 

####mysql 
    
    dnf -y install mysql-server; \
    systemctl enable mariadb.service; \
    mysql_secure_installation;

    dnf -y install phpMyAdmin; \
    service httpd reload;

####php
    
    dnf -y install php-cli;\
    dnf -y install php;\
    dnf -y install php-devel;\
    dnf -y install php-xml;\
    dnf -y install php-pdo;\
    dnf -y install php-posix;\
    dnf -y install php-intl;\
    dnf -y install php-mbstring;\
    dnf -y install php-imap;

####conf php et apache
    
    echo "date.timezone = 'Europe/Paris'" >> /etc/php.ini; \
    echo "# Include vhost conf" >> /etc/httpd/conf/httpd.conf; \
    echo "Include /data/conf/*.conf" >> /etc/httpd/conf/httpd.conf; \
    echo "<Directory /> " >> /etc/httpd/conf/httpd.conf; \
    echo "    Options Indexes FollowSymLinks Includes ExecCGI" >> /etc/httpd/conf/httpd.conf; \
    echo "    AllowOverride All" >> /etc/httpd/conf/httpd.conf; \
    echo "    Order deny,allow" >> /etc/httpd/conf/httpd.conf; \
    echo "    Allow from all" >> /etc/httpd/conf/httpd.conf; \
    echo "</Directory>" >> /etc/httpd/conf/httpd.conf; 

**Warning: remove all httpd.conf "Includes"**

####pecl
    dnf -y install php-pear; \
    dnf -y install gcc;

####graphviz
    
    dnf -y install graphviz; \

####Node 
    dnf -y install nodejs npm; \
    npm install -g less; \ 
    npm install -g less-plugin-autoprefix; \
    npm install -g less-plugin-group-css-media-queries;

####ImageMagick
    dnf -y install ImageMagick;\
    dnf -y install ImageMagick-devel;\
    echo -e "\033[1;33m IMAGICK : Compilation avec pecl de imagick-3.1.0RC2 (dernière version fonctionnelle sur php > 5.4)\033[0m";\
    pecl install imagick;\
    echo "extension=imagick.so" > /etc/php.d/imagick.ini;\
    service httpd restart;

####Parallel
    dnf -y install parallel;


















tutum-docker-lamp
=================

[![Deploy to Tutum](https://s.tutum.co/deploy-to-tutum.svg)](https://dashboard.tutum.co/stack/deploy/)

Out-of-the-box LAMP image (PHP+MySQL)


Usage
-----

To create the image `tutum/lamp`, execute the following command on the tutum-docker-lamp folder:

	docker build -t tutum/lamp .

You can now push your new image to the registry:

	docker push tutum/lamp


Running your LAMP docker image
------------------------------

Start your image binding the external ports 80 and 3306 in all interfaces to your container:

	docker run -d -p 80:80 -p 3306:3306 tutum/lamp

Test your deployment:

	curl http://localhost/

Hello world!


Loading your custom PHP application
-----------------------------------

In order to replace the "Hello World" application that comes bundled with this docker image,
create a new `Dockerfile` in an empty folder with the following contents:

	FROM tutum/lamp:latest
	RUN rm -fr /app && git clone https://github.com/username/customapp.git /app
	EXPOSE 80 3306
	CMD ["/run.sh"]

replacing `https://github.com/username/customapp.git` with your application's GIT repository.
After that, build the new `Dockerfile`:

	docker build -t username/my-lamp-app .

And test it:

	docker run -d -p 80:80 -p 3306:3306 username/my-lamp-app

Test your deployment:

	curl http://localhost/

That's it!


Connecting to the bundled MySQL server from within the container
----------------------------------------------------------------

The bundled MySQL server has a `root` user with no password for local connections.
Simply connect from your PHP code with this user:

	<?php
	$mysql = new mysqli("localhost", "root");
	echo "MySQL Server info: ".$mysql->host_info;
	?>


Connecting to the bundled MySQL server from outside the container
-----------------------------------------------------------------

The first time that you run your container, a new user `admin` with all privileges
will be created in MySQL with a random password. To get the password, check the logs
of the container by running:

	docker logs $CONTAINER_ID

You will see an output like the following:

	========================================================================
	You can now connect to this MySQL Server using:

	    mysql -uadmin -p47nnf4FweaKu -h<host> -P<port>

	Please remember to change the above password as soon as possible!
	MySQL user 'root' has no password but only allows local connections
	========================================================================

In this case, `47nnf4FweaKu` is the password allocated to the `admin` user.

You can then connect to MySQL:

	 mysql -uadmin -p47nnf4FweaKu

Remember that the `root` user does not allow connections from outside the container -
you should use this `admin` user instead!


Setting a specific password for the MySQL server admin account
--------------------------------------------------------------

If you want to use a preset password instead of a random generated one, you can
set the environment variable `MYSQL_PASS` to your specific password when running the container:

	docker run -d -p 80:80 -p 3306:3306 -e MYSQL_PASS="mypass" tutum/lamp

You can now test your new admin password:

	mysql -uadmin -p"mypass"


Disabling .htaccess
--------------------

`.htaccess` is enabled by default. To disable `.htaccess`, you can remove the following contents from `Dockerfile`

	# config to enable .htaccess
    ADD apache_default /etc/apache2/sites-available/000-default.conf
    RUN a2enmod rewrite


**by http://www.tutum.co**
