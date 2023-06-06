FROM docker.io/ubuntu:20.04 as builder

RUN apt-get update \
 && apt-get install -y libeccodes0 m4 zlib1g-dev libcurl4-gnutls-dev libpng-dev \
 && apt-get install -y bc screen rsync rclone vim file csh ksh htop nmon \
 && apt-get install -y openmpi-*

WORKDIR /tmp/

ADD https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-1.8/hdf5-1.8.23/src/hdf5-1.8.23.tar.bz2 .

FROM docker.io/ubuntu:20.04 as ubuntu-meteorology-env
MAINTAINER Tianjie Wu "wutj@cma.gov.cn" 

RUN apt-get update \
 && apt-get install -y libeccodes0 m4 zlib1g-dev libcurl4-gnutls-dev libpng-dev \
 && apt-get install -y bc screen rsync rclone vim file csh ksh htop nmon \
 && apt-get install -y openmpi-*


