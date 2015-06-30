FROM fedora:22
MAINTAINER lioshi <lioshi@lioshi.com>

RUN dnf -y update && dnf -y install httpd-manual && service httpd start && chkconfig httpd on