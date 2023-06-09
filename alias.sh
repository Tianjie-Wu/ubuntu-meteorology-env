alias cd..='cd ..'
alias dir='ls -lh --color=auto'
alias l='ls -alF --color=auto'
alias la='ls -la --color=auto'
alias ll='ls -lh --color=auto'
alias ls-l='ls -l --color=auto'
alias grep='grep --color=auto'
alias ..='cd ..'
alias ...='cd ../..'

# use 'locale -a' to check
export LC_ALL="C"

PS1="[\e[30;45m\A\e[0m \e[30;42mubuntu-meteorology-env\e[0m:\e[33m\w\e[0m]\n$ "

export HISTTIMEFORMAT='%F %T '
export HISTCONTROL=ignorespace
export HISTIGNORE='pwd:ls:ll:top:df -h:history:'
export HISTCONTROL=erasedups
export HISTSIZE=1000
export HISTFILESIZE=1000

# CC=icc FC=ifort CXX=icpc LDFLAGS=-L/usr/local/lib CPPFLAGS=-I/usr/local/include ./configure --prefix=/usr/local
# source /opt/intel/2018.4/bin/compilervars.sh intel64

export LOCALIB=/usr/local
export PATH=$LOCALIB/bin:$PATH
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$LOCALIB/lib
export LD_RUN_PATH=$LD_RUN_PATH:$LOCALIB/lib
export LD_INCLUDE_PATH=$LD_INCLUDE_PATH:$LOCALIB/include
export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:$LOCALIB/lib/pkgconfig

export NETCDF=/usr/local
export NETCDF_LIB=$NETCDF/lib
export NETCDF_INC=$NETCDF/include
export HDF5=/usr/local
export NETCDF=/usr/local
export NETCDF_Fortran_LIBRARY=/usr/local/lib
export NETCDF_PATH=/usr/local
export WRFIO_NCD_LARGE_FILE_SUPPORT=1
export PIO=/usr/local
export JASPERLIB=/usr/local/lib
export JASPERINC=/usr/local/include

