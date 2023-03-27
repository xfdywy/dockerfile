#fasdfas


ARG BASE_IMAGE
ARG INSTALLER_IMAGE
ARG VALIDATOR_IMAGE
ARG IMAGE_FRAMEWORK
ARG IMAGE_ACCELERATOR
ARG IMAGE_SKU

FROM $BASE_IMAGE as base
FROM $INSTALLER_IMAGE as installer
FROM $VALIDATOR_IMAGE as validator

FROM base

# FROM nvidia/cuda:11.3.0-cudnn8-devel-ubuntu18.04
ENV TZ=America/Vancouver
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apt-get update && \
    apt-get upgrade -y -o Dpkg::Options::="--force-confold" && \
    apt-get -y install locales sudo && \
    echo "C.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV LC_ALL=C.UTF-8 \
    LANG=C.UTF-8 \
    LANGUAGE=C.UTF-8

ENV FENICS_HOME /fenics
RUN mkdir $FENICS_HOME/ && touch $FENICS_HOME/.sudo_as_admin_successful && \
    mkdir $FENICS_HOME/shared


##########1 done#################

##########2 start######################
WORKDIR /workspace

# Environment variables
ENV PETSC_VERSION=3.12.3 \
    SLEPC_VERSION=3.12.1 \
    PYBIND11_VERSION=2.4.3 \
    MPI4PY_VERSION=3.0.3 \
    PETSC4PY_VERSION=3.12.0 \
    SLEPC4PY_VERSION=3.12.0 \
    TRILINOS_VERSION=12.10.1 \
    OPENBLAS_NUM_THREADS=1 \
    OPENBLAS_VERBOSE=0 \
    FENICS_PREFIX=$FENICS_HOME/local

# Non-Python utilities and libraries
RUN apt-get -qq update && \
    apt-get -y --with-new-pkgs \
        -o Dpkg::Options::="--force-confold" upgrade && \
    apt-get -y install curl && \
    curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | bash && \
    apt-get -y install \
        bison \
        ccache \
        cmake \
        doxygen \
        flex \
        figlet\
        g++ \
        gfortran \
        git \
        git-lfs \
        graphviz \
        libboost-filesystem-dev \
        libboost-iostreams-dev \
        libboost-math-dev \
        libboost-program-options-dev \
        libboost-system-dev \
        libboost-thread-dev \
        libboost-timer-dev \
        libeigen3-dev \
        libfreetype6-dev \
        liblapack-dev \
        libmpich-dev \
        libopenblas-dev \
        libpcre3-dev \
        libpng-dev \
        libhdf5-mpich-dev \
        libgmp-dev \
        libcln-dev \
        libmpfr-dev \
        man \
        mpich \
        nano \
        make\
        pkg-config \
        vim \
        wget \       
        sudo \
        locate \
        build-essential \
        wget \
        tar \
        bzip2 \
        environment-modules \
        libhwloc-dev \
        hwloc \
        libhwloc-common \
        libhwloc-plugins \
        openssh-server \
        binutils \
        tcl \
        libibverbs-dev \
        bash-completion && \
    git lfs install && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*



RUN apt-get -y update && \
    apt-get -y install \
      build-essential \
      autotools-dev \
      rsync \
      curl \
      wget \
      jq \
      openssh-server \
      openssh-client \
    # No longer in 'minimal set of packages'
      sudo \
    # Needed by OpenMPI
      cmake \
      g++ \
      gcc \
    # ifconfig
      net-tools && \
    apt-get autoremove


RUN apt update && apt  install  -y --allow-change-held-packages --no-install-recommends \
         git \
         ca-certificates \
         libnccl2 \
         libnccl-dev \
         libjpeg-dev \
         libboost-all-dev\
         libsdl2-dev\
         libgl1-mesa-dev\
         swig\
         vim\
         tmux\
         htop\
         xorg-dev\
         unzip\
         cmake zlib1g-dev libjpeg-dev xvfb libosmesa6-dev\
         libpng-dev curl wget &&\
         rm -rf /var/lib/apt/lists/*

RUN wget https://github.com/openucx/ucx/releases/download/v1.5.0/ucx-1.5.0.tar.gz -P /tmp/ && \
    tar xzf /tmp/ucx-1.5.0.tar.gz -C /tmp && \
    cd /tmp/ucx-1.5.0 && \
    ./configure --prefix=/usr/local/lifli/ucx && \
    make -j `nproc` && \
    make install

RUN wget https://download.open-mpi.org/release/open-mpi/v4.0/openmpi-4.0.0.tar.gz -P /tmp/ && \
    tar xzf /tmp/openmpi-4.0.0.tar.gz -C /tmp && \
    cd /tmp/openmpi-4.0.0 && \
    ./configure --with-ucx=/usr/local/lifli/ucx/ --prefix=/usr/local/lifli/openmpi && \
    make -j `nproc` && \
    make install


RUN wget https://github.com/NVIDIA/nccl/archive/refs/tags/v2.9.9-1.tar.gz -P /tmp/ && \
    tar xzf /tmp/v2.9.9-1.tar.gz -C /tmp/ && \
    make -j `nproc` -C /tmp/nccl-2.9.9-1 MPI=1 MPI_HOME=/usr/local/lifli/openmpi/ && \
    cp -r /tmp/nccl-2.9.9-1/build /usr/local/lifli/nccl

 
ENV PYTHON_VERSION=3.8
RUN wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh  -O ~/miniconda.sh    && \
     chmod +x ~/miniconda.sh && \
     ~/miniconda.sh -b -p /opt/conda && \
     rm ~/miniconda.sh && \
     /opt/conda/bin/conda create -y --name pytorch-py$PYTHON_VERSION -c conda-forge mshr=2019.1.0=py38h255090a_2&& \
     /opt/conda/bin/conda clean -ya

ENV PATH /opt/conda/envs/pytorch-py$PYTHON_VERSION/bin:$PATH

# # Install PETSc from source
# RUN apt-get -qq update && \
#     # apt-get -y install \
#         # python-minimal && \
#     wget -nc --quiet https://gitlab.com/petsc/petsc/-/archive/v${PETSC_VERSION}/petsc-v${PETSC_VERSION}.tar.gz -O petsc-${PETSC_VERSION}.tar.gz && \
#     mkdir -p petsc-src && tar -xf petsc-${PETSC_VERSION}.tar.gz -C petsc-src --strip-components 1 && \
#     cd petsc-src && \
#     ./configure --COPTFLAGS="-O2" \
#                 --CXXOPTFLAGS="-O2" \
#                 --FOPTFLAGS="-O2" \
#                 --with-fortran-bindings=no \
#                 --with-debugging=0 \
#                 --download-blacs \
#                 --download-hypre \
#                 --download-metis \
#                 --download-mumps \
#                 --download-ptscotch \
#                 --download-scalapack \
#                 --download-spai \
#                 --download-suitesparse \
#                 --download-superlu \
#                 --prefix=/usr/local/petsc-32 && \
#      make && \
#      make install && \
#      rm -rf /tmp/*

RUN /opt/conda/envs/pytorch-py3.8/bin/python3 -m pip install cython
WORKDIR /workspace
# Install PETSc from git
RUN git clone -b release https://gitlab.com/petsc/petsc.git petsc &&\
            cd petsc &&\
            ./configure --with-cc=gcc --with-cxx=g++ --with-fc=gfortran --with-petsc4py --download-mpich       --download-fblaslapack     --download-hypre \
                --download-metis \
                --download-mumps \
                --download-ptscotch \
                --download-scalapack \
                --download-spai \
                --download-suitesparse \
                --download-superlu \
                --prefix=/usr/local/petsc-32  &&\
            make PETSC_DIR=/workspace/petsc PETSC_ARCH=arch-linux-c-debug all &&\
            make PETSC_DIR=/workspace/petsc PETSC_ARCH=arch-linux-c-debug install

# # Install SLEPc from git
RUN  git clone https://gitlab.com/slepc/slepc &&\
            cd slepc &&\
            git checkout release &&\
            export PETSC_DIR=/usr/local/petsc-32 &&\
            ./configure  --prefix=/usr/local/slepc-32 --with-clean &&\
            make -j all check ; make SLEPC_DIR=/workspace/slepc PETSC_DIR=/usr/local/petsc-32 install
            # 

# # Install SLEPc from source
# # NOTE: Had issues building SLEPc from source tarball generated by bitbucket.
# # Website tarballs work fine, however.
# RUN apt-get -qq update && \
#     apt-get -y install \
#         python-minimal && \
#     wget -nc --quiet https://gitlab.com/slepc/slepc/-/archive/v${SLEPC_VERSION}/slepc-v${SLEPC_VERSION}.tar.gz -O slepc-${SLEPC_VERSION}.tar.gz && \
#     mkdir -p slepc-src && tar -xf slepc-${SLEPC_VERSION}.tar.gz -C slepc-src --strip-components 1 && \
#     export PETSC_DIR=/usr/local/petsc-32 && \
#     cd slepc-src && \
#     ./configure --prefix=/usr/local/slepc-32 && \
#     make SLEPC_DIR=$(pwd) && \
#     make install && \
#     rm -rf /tmp/*

# # By default use the 32-bit build of SLEPc and PETSc.
# ENV SLEPC_DIR=/usr/local/slepc-32 \
#     PETSC_DIR=/usr/local/petsc-32

# Install jupyterlab, sympy, mpi4py, petsc4py, slepc4py and pybind11 from source.
RUN pip install --no-cache-dir jupyter jupyterlab matplotlib sympy==1.1.1 pkgconfig && \
    pip install --no-cache-dir https://github.com/mpi4py/mpi4py/archive/${MPI4PY_VERSION}.tar.gz && \
    pip install --no-cache-dir    petsc4py  slepc4py && \
    # pip install --no-cache-dir https://bitbucket.org/slepc/slepc4py/downloads/slepc4py-${SLEPC4PY_VERSION}.tar.gz && \
    pip install --no-cache-dir pybind11==${PYBIND11_VERSION} && \
    wget -nc --quiet https://github.com/pybind/pybind11/archive/v${PYBIND11_VERSION}.tar.gz && \
    tar -xf v${PYBIND11_VERSION}.tar.gz && \
    cd pybind11-${PYBIND11_VERSION} && \
    mkdir build && \
    cd build && \
    cmake -DPYBIND11_TEST=False ../ && \
    make && \
    make install && \
    rm -rf /tmp/*


#################2 done#####################

#################3 start#####################

ENV FENICS_PYTHON=python3
ENV DOLFIN_VERSION="2019.1.0.post0"
ENV MSHR_VERSION="2019.1.0"
ENV PYPI_FENICS_VERSION=">=2019.1.0,<2019.2.0"

WORKDIR /tmp
RUN /bin/bash -c "PIP_NO_CACHE_DIR=off ${FENICS_PYTHON} -m pip install 'fenics${PYPI_FENICS_VERSION}' && \
                  git clone https://bitbucket.org/fenics-project/dolfin.git && \
                  cd dolfin && \
                  git checkout ${DOLFIN_VERSION} && \
                  mkdir build && \
                  cd build && \
                  cmake ../ && \
                  make -j && \
                  make install && \
                #   mv /usr/local/share/dolfin/demo /tmp/demo && \
                #   mkdir -p /usr/local/share/dolfin/demo && \
                #   mv /tmp/demo /usr/local/share/dolfin/demo/cpp && \
                  cd ../python && \
                  PIP_NO_CACHE_DIR=off ${FENICS_PYTHON} -m pip install . && \
                  cd demo && \
                  python3 generate-demo-files.py && \
                  mkdir -p /usr/local/share/dolfin/demo/python && \
                  cp -r documented /usr/local/share/dolfin/demo/python && \
                  cp -r undocumented /usr/local/share/dolfin/demo/python && \
                  cd /tmp/ && \
                  rm -rf /tmp/*"

#################3 done#####################
 
#################4 start#####################

RUN /opt/conda/bin/conda install --name pytorch-py3.8 mshr=2019.1.0=py38h255090a_2
RUN pip install h5py keras future pygmsh gmsh meshio[all]

RUN pip install  gym==0.12.0   && \
    pip install  gym[atari]  && \
    pip install opencv-python && \
    pip install tqdm   && \
    pip install   pytz logger matplotlib scikit-image && \
    pip install numpy && \
    pip install pandas && \
    pip install tensorflow  && \
    pip install tensorboard  patchelf
    

# # ENV PATH /opt/conda/envs/pytorch-py$PYTHON_VERSION/bin:$PATH
WORKDIR /workspace
RUN chmod -R a+w /workspace

# ENV LANG C.UTF-8
# RUN echo "export PATH=$PATH:/opt/conda/bin/" >> /etc/profile

# RUN /opt/conda/bin/conda install --name pytorch-py$PYTHON_VERSION patchelf

RUN wget "https://msramlstorage1.blob.core.windows.net/yuewang/data/mujoco.tar?sp=r&st=2020-09-14T13:01:33Z&se=2099-06-29T21:01:33Z&spr=https,http&sv=2019-12-12&sr=b&sig=1xbPid8dhCa45igtl%2FYfX%2F9ec6mVsXneImv7gPLrmDQ%3D" -O mujoco.tar  && tar -xvf mujoco.tar
# #&& cp -r .mujoco /root/.mujoco

# ENV PATH $PATH:/opt/conda/bin
# EXPOSE 22

RUN wget "https://msramlstorage1.blob.core.windows.net/yuewang/data/run.sh?sp=r&st=2020-09-14T13:37:06Z&se=2099-09-14T21:37:06Z&spr=https,http&sv=2019-12-12&sr=b&sig=uog7tRpmb7jnY%2BZf6O%2BjMG4oufOQToqe2PkPKRvV6eQ%3D" -O /workspace/run.sh



# # ENV  LD_LIBRARY_PATH /workspace/.mujoco/mjpro150/bin:$LD_LIBRARY_PATH
# # ENV  MUJOCO_PY_MJPRO_PATH /workspace/.mujoco/mjpro150/
# # ENV  MUJOCO_PY_MJKEY_PATH /workspace/.mujoco/mjkey.txt
# # ENV  MJKEY_PATH /workspace/.mujoco/mjkey.txt
# # ENV  MJLIB_PATH /workspace/.mujoco/mujoco200_linux/bin/libmujoco200.so

ENV  LD_LIBRARY_PATH /workspace/.mujoco/mujoco200_linux/bin:$LD_LIBRARY_PATH
ENV  MUJOCO_PY_MJPRO_PATH /workspace/.mujoco/mujoco200_linux/
ENV  MUJOCO_PY_MUJOCO_PATH /workspace/.mujoco/mujoco200_linux/
ENV  MUJOCO_PY_MJKEY_PATH /workspace/.mujoco/mjkey.txt
ENV  MJKEY_PATH /workspace/.mujoco/mjkey.txt
ENV  MJLIB_PATH /workspace/.mujoco/mujoco200_linux/bin/libmujoco200.so


# RUN   pip install pandas roboschool tensorflow==1.14
# WORKDIR /opt
RUN git clone https://github.com/openai/baselines.git \
&& cd baselines \
&& pip3 install -e .




# # RUN export LD_LIBRARY_PATH=/workspace/.mujoco/mjpro150/bin:$LD_LIBRARY_PATH &&
RUN pip3 install mujoco-py==2.0.2.0
# # RUN pip install mujoco-py==1.50.1.68
# # RUN echo $LD_LIBRARY_PATH && echo $MJLIB_PATH
RUN   pip3 install git+https://github.com/aravindr93/mjrl.git
RUN   pip3 install git+https://github.com/xfdywy/d4rl.git
# # && pip install git+https://github.com/takuseno/d4rl-pybullet && pip install pybullet


# ENV PATH $PATH:/opt/conda/bin


# RUN apt update && apt  install  -y --allow-change-held-packages --no-install-recommends \
#         libglew-dev libglfw3-dev && \
#          rm -rf /var/lib/apt/lists/*


# RUN /opt/conda/bin/conda  install -n pytorch-py$PYTHON_VERSION pytorch==1.11.0 torchvision torchaudio cudatoolkit=11.3 -c pytorch

RUN pip install torch torchvision  --extra-index-url https://download.pytorch.org/whl/cu113
RUN chmod -R 777 /workspace




# RUN PATH=$PATH:/usr/local/lifli/openmpi/bin/ LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lifli/openmpi/lib/ HOROVOD_NCCL_HOME=/usr/local/lifli/nccl/ HOROVOD_NCCL_INCLUDE=/usr/local/lifli/nccl/include/ HOROVOD_NCCL_LIB=/usr/local/lifli/nccl/lib/ HOROVOD_WITH_MPI=1 HOROVOD_GPU_OPERATIONS=NCCL HOROVOD_GPU_ALLREDUCE=NCCL HOROVOD_WITH_PYTORCH=1
RUN HOROVOD_GPU_OPERATIONS=NCCL pip install --no-cache-dir horovod[pytorch]  
# && horovodrun --check-build

# get the installation scripts
COPY --from=installer /installer /opt/microsoft/_singularity/installations/

# install components required for running this image in Singularity
RUN /opt/microsoft/_singularity/installations/singularity/installer.sh

# get the validation scripts
COPY --from=validator /validations /opt/microsoft/_singularity/validations/

# set validation arguments for expected use of this image
ENV SINGULARITY_IMAGE_FRAMEWORK=$IMAGE_FRAMEWORK
ENV SINGULARITY_IMAGE_ACCELERATOR=$IMAGE_ACCELERATOR
ENV SINGULARITY_IMAGE_ACCELERATOR_SKU=$IMAGE_SKU
#################4 done#####################
    
# VOLUME /home/fenics/shared
 
WORKDIR /workspace
