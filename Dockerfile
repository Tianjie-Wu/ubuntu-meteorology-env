### /^[1-9]\d{3}-(0[1-9]|1[0-2])-(0[1-9]|[1-2][0-9]|3[0-1])$/
### 0
FROM docker.io/ubuntu:20.04 as builder

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

RUN apt-get update \
 && apt-get install -y libeccodes0 m4 zlib1g-dev libcurl4-gnutls-dev libpng-dev liblapack-dev\
 && apt-get install -y wget bc screen rsync rclone vim file csh ksh htop nmon bzip2\
 && apt-get install -y openmpi-* g++ gfortran make coreutils cmake

### 1
FROM builder as hdf5-netcdf-builder
WORKDIR /tmp/

ENV LOCALIB=/usr/local
ENV PATH=$LOCALIB/bin:$PATH
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$LOCALIB/lib
ENV LD_RUN_PATH=$LD_RUN_PATH:$LOCALIB/lib
ENV LD_INCLUDE_PATH=$LD_INCLUDE_PATH:$LOCALIB/include
ENV PKG_CONFIG_PATH=$PKG_CONFIG_PATH:$LOCALIB/lib/pkgconfig

# RUN wget https://support.hdfgroup.org/ftp/lib-external/szip/2.1.1/src/szip-2.1.1.tar.gz
RUN wget https://csdn-468674-transfer.s3.cn-north-1.jdcloud-oss.com/docker/ubuntu-meteorology-env/20.04/szip-2.1.1.tar
# RUN wget http://www.ijg.org/files/jpegsrc.v9e.tar.gz
RUN wget https://csdn-468674-transfer.s3.cn-north-1.jdcloud-oss.com/docker/ubuntu-meteorology-env/20.04/jpegsrc.v9e.tar.gz
# RUN wget https://support.hdfgroup.org/ftp/HDF/releases/HDF4.2.16/src/hdf-4.2.16.tar.bz2
RUN wget https://csdn-468674-transfer.s3.cn-north-1.jdcloud-oss.com/docker/ubuntu-meteorology-env/20.04/hdf-4.2.16.tar.bz2
# RUN wget https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-1.8/hdf5-1.8.23/src/hdf5-1.8.23.tar.bz2 
RUN wget https://csdn-468674-transfer.s3.cn-north-1.jdcloud-oss.com/docker/ubuntu-meteorology-env/20.04/hdf5-1.8.23.tar.bz2
# RUN wget https://codeload.github.com/Unidata/netcdf-c/tar.gz/refs/tags/v4.8.1 -O netcdf-c-4.8.1.tar.gz
RUN wget https://csdn-468674-transfer.s3.cn-north-1.jdcloud-oss.com/docker/ubuntu-meteorology-env/20.04/netcdf-c-4.8.1.tar.gz
# RUN wget https://codeload.github.com/Unidata/netcdf-fortran/tar.gz/refs/tags/v4.5.3 -O netcdf-fortran-4.5.3.tar.gz
RUN wget https://csdn-468674-transfer.s3.cn-north-1.jdcloud-oss.com/docker/ubuntu-meteorology-env/20.04/netcdf-fortran-4.5.3.tar.gz

RUN tar -xvf szip-2.1.1.tar
RUN tar -xvf jpegsrc.v9e.tar.gz
RUN tar -xvf hdf-4.2.16.tar.bz2
RUN tar -xvf hdf5-1.8.23.tar.bz2 
RUN tar -xvf netcdf-c-4.8.1.tar.gz
RUN tar -xvf netcdf-fortran-4.5.3.tar.gz

WORKDIR /tmp/szip-2.1.1

RUN ./configure --prefix=/usr/local --with-pic
RUN make -j `nproc`
RUN make install

WORKDIR /tmp/jpeg-9e

RUN ./configure --prefix=/usr/local 
RUN make -j `nproc`
RUN make install

WORKDIR /tmp/hdf-4.2.16

RUN ./configure --prefix=/usr/local --enable-fortran --disable-netcdf --with-pic
RUN make -j `nproc`
RUN make install

WORKDIR /tmp/hdf5-1.8.23

RUN ./configure --prefix=/usr/local --enable-fortran --enable-hdf4 --with-szlib=/usr/local
RUN make -j `nproc`
RUN make install

WORKDIR /tmp/netcdf-c-4.8.1

RUN CC=gcc FC=gfortran LDFLAGS=-L/usr/local/lib CPPFLAGS=-I/usr/local/include ./configure --prefix=/usr/local  --enable-hdf4
RUN make -j `nproc`
RUN make install

WORKDIR /tmp/netcdf-fortran-4.5.3

RUN CC=gcc FC=gfortran LDFLAGS=-L/usr/local/lib CPPFLAGS=-I/usr/local/include ./configure --prefix=/usr/local
RUN make -j `nproc`
RUN make install

### 2 
FROM builder as grib_api-builder

COPY --from=hdf5-netcdf-builder /usr/local/ /usr/local/

WORKDIR /tmp/

RUN wget https://csdn-468674-transfer.s3.cn-north-1.jdcloud-oss.com/docker/ubuntu-meteorology-env/20.04/jasper-1.900.1.tar.gz
RUN wget https://csdn-468674-transfer.s3.cn-north-1.jdcloud-oss.com/docker/ubuntu-meteorology-env/20.04/grib_api-1.27.0-Source.tar.gz
RUN wget https://csdn-468674-transfer.s3.cn-north-1.jdcloud-oss.com/docker/ubuntu-meteorology-env/20.04/wgrib.tar
RUN wget https://csdn-468674-transfer.s3.cn-north-1.jdcloud-oss.com/docker/ubuntu-meteorology-env/20.04/wgrib2.tgz

RUN tar -xvf jasper-1.900.1.tar.gz
RUN tar -xvf grib_api-1.27.0-Source.tar.gz
RUN mkdir wgrib
RUN tar -xvf wgrib.tar -C ./wgrib/
RUN tar -xvf wgrib2.tgz

WORKDIR /tmp/jasper-1.900.1

RUN CC=gcc FC=gfortran LDFLAGS=-L/usr/local/lib CPPFLAGS=-I/usr/local/include ./configure --prefix=/usr/local --with-pic 
RUN make -j `nproc`
RUN make install

WORKDIR /tmp/grib_api-1.27.0-Source

RUN mkdir build
WORKDIR build
RUN CC=gcc FC=gfortran LDFLAGS=-L/usr/local/lib CPPFLAGS=-I/usr/local/include cmake ../ -DCMAKE_INSTALL_PREFIX=/usr/local
RUN make -j `nproc`
RUN make install

WORKDIR /tmp/wgrib

RUN CC=gcc FC=gfortran LDFLAGS=-L/usr/local/lib CPPFLAGS=-I/usr/local/include make -j `nproc`
RUN cp wgrib /usr/local/bin/

WORKDIR /tmp/grib2
RUN CC=gcc FC=gfortran LDFLAGS=-L/usr/local/lib CPPFLAGS=-I/usr/local/include make
RUN cp ./wgrib2/wgrib2 /usr/local/bin

### final
FROM builder as ubuntu-meteorology-env
MAINTAINER Tianjie Wu "wutj@cma.gov.cn" 

COPY ./alias.sh /root/.bash_aliases
COPY --from=grib_api-builder /usr/local/ /usr/local/
CMD ["/bin/bash"]

