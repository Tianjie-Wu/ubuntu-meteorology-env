### 0
FROM docker.io/ubuntu:20.04 as builder

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

RUN apt-get update \
 && apt-get install -y libeccodes0 m4 zlib1g-dev libcurl4-gnutls-dev libpng-dev \
 && apt-get install -y wget bc screen rsync rclone vim file csh ksh htop nmon \
 && apt-get install -y openmpi-* g++ make coreutils

### 1
FROM builder as hdf5-netcdf-builder
WORKDIR /tmp/

RUN wget https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-1.8/hdf5-1.8.23/src/hdf5-1.8.23.tar.bz2 
RUN wget https://codeload.github.com/Unidata/netcdf-c/tar.gz/refs/tags/v4.8.1
RUN wget https://codeload.github.com/Unidata/netcdf-fortran/tar.gz/refs/tags/v4.5.3

RUN tar -xvf hdf5-1.8.23.tar.bz2 
RUN tar -xvf v4.8.1
RUN tar -xvf v4.5.3

WORKDIR /tmp/hdf5-1.8.23

RUN ./configure --prefix=/usr/local --enable-fortran
RUN make -j `nproc`
RUN make install

WORKDIR /tmp/netcdf-c-4.8.1

RUN CC=gcc FC=gfortran LDFLAGS=-L/usr/local/lib CPPFLAGS=-I/usr/local/include ./configure --prefix=/usr/local
RUN make -j `nproc`
RUN make install

WORKDIR /tmp/netcdf-fortran-4.5.3

RUN CC=gcc FC=gfortran LDFLAGS=-L/usr/local/lib CPPFLAGS=-I/usr/local/include ./configure --prefix=/usr/local
RUN make -j `nproc`
RUN make install

### final
FROM builder as ubuntu-meteorology-env
MAINTAINER Tianjie Wu "wutj@cma.gov.cn" 

COPY ./alias.sh /root/.bash_aliases
COPY --from=hdf5-netcdf-builder /usr/local/ /usr/local/
CMD ["/bin/bash"]

