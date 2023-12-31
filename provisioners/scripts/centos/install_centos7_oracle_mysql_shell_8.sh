#!/bin/sh -eux
# install oracle mysql shell command-line utility on centos linux 7.x.

# set default value for cnao lab devops home environment variable if not set. -----------------------
devops_home="${devops_home:-/opt/cnao-lab-devops}"

# create scripts directory (if needed). ------------------------------------------------------------
mkdir -p ${devops_home}/provisioners/scripts/centos
cd ${devops_home}/provisioners/scripts/centos

# install mysql shell. -----------------------------------------------------------------------------
mysqlsh_release="8.0.35-1"
mysqlsh_binary="mysql-shell-${mysqlsh_release}.el7.x86_64.rpm"
mysqlsh_checksum="43fac0423c7fc0221599e32ff7715494"

# download mysql shell repository.
rm -f ${mysqlsh_binary}
wget --no-verbose --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" https://dev.mysql.com/get/Downloads/MySQL-Shell/${mysqlsh_binary}

# verify the downloaded binary using the md5 checksum.
echo "${mysqlsh_checksum} ${mysqlsh_binary}" | md5sum --check -
# amazon-corretto-${jdk_build}-linux-x64.tar.gz: OK

# install mysql shell. -----------------------------------------------------------------------------
yum -y install ${mysqlsh_binary}

# verify mysql shell installation.
mysqlsh --version

# mysqlsh command-line examples. -------------------------------------------------------------------
# MySQL Shell User Guide
#   This is the MySQL Shell User Guide extract from the MySQL 8.0 Reference Manual.
#   https://dev.mysql.com/doc/mysql-shell-excerpt/8.0/en/
#
#   For help with using MySQL, please visit either the MySQL Forums or MySQL Mailing Lists,
#   where you can discuss your issues with other MySQL users.
#
# Example Usage:
#   $ mysqlsh
#   MySQL JS > \connect root@localhost:3306
#   MySQL JS > \sql
#   MySQL JS > show databases;
#   MySQL JS > \use mysql
#   MySQL JS > show tables;
#   MySQL JS > \exit
