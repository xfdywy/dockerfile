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

ENV TZ=America/Vancouver

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apt-get update && \
    apt-get install --no-install-recommends --no-install-suggests -yq \
        figlet \
        sudo \
        make \
        vim \
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
        libibverbs-dev && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get purge --auto-remove && \
    apt-get clean && \
    figlet Singularity

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


##############self add ##############################

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

ENV PYTHON_VERSION=3.7
RUN wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh  -O ~/miniconda.sh    && \
     chmod +x ~/miniconda.sh && \
     bash ~/miniconda.sh -b -p /opt/conda && \
     rm ~/miniconda.sh && \
     /opt/conda/bin/conda create -y --name pytorch-py$PYTHON_VERSION python=$PYTHON_VERSION numpy pyyaml scipy ipython mkl&& \
     /opt/conda/bin/conda clean -ya

ENV PATH /opt/conda/envs/pytorch-py$PYTHON_VERSION/bin:$PATH

RUN /opt/conda/bin/conda install --name pytorch-py$PYTHON_VERSION  pytorch=1.11.0 torchvision cudatoolkit=11.3  -c pytorch  && \
    /opt/conda/bin/conda clean -ya




RUN pip install h5py keras future chainer

RUN pip install  gym==0.12.0   && \
    pip install  gym[atari]  && \
    pip install opencv-python && \
    pip install tqdm   && \
    pip install   pytz logger matplotlib scikit-image


# Run     /opt/conda/bin/conda install pybox2d -c conda-forge

WORKDIR /opt


ENV PATH /opt/conda/envs/pytorch-py$PYTHON_VERSION/bin:$PATH
WORKDIR /workspace
RUN chmod -R a+w /workspace


ENV LANG C.UTF-8
RUN echo "export PATH=$PATH:/opt/conda/bin/" >> /etc/profile

RUN /opt/conda/bin/conda install --name pytorch-py$PYTHON_VERSION patchelf

RUN wget "https://msramlstorage1.blob.core.windows.net/yuewang/data/mujoco.tar?sp=r&st=2020-09-14T13:01:33Z&se=2099-06-29T21:01:33Z&spr=https,http&sv=2019-12-12&sr=b&sig=1xbPid8dhCa45igtl%2FYfX%2F9ec6mVsXneImv7gPLrmDQ%3D" -O mujoco.tar  && tar -xvf mujoco.tar
#&& cp -r .mujoco /root/.mujoco

ENV PATH $PATH:/opt/conda/bin
EXPOSE 22

RUN wget "https://msramlstorage1.blob.core.windows.net/yuewang/data/run.sh?sp=r&st=2020-09-14T13:37:06Z&se=2099-09-14T21:37:06Z&spr=https,http&sv=2019-12-12&sr=b&sig=uog7tRpmb7jnY%2BZf6O%2BjMG4oufOQToqe2PkPKRvV6eQ%3D" -O /workspace/run.sh



# ENV  LD_LIBRARY_PATH /workspace/.mujoco/mjpro150/bin:$LD_LIBRARY_PATH
# ENV  MUJOCO_PY_MJPRO_PATH /workspace/.mujoco/mjpro150/
# ENV  MUJOCO_PY_MJKEY_PATH /workspace/.mujoco/mjkey.txt
# ENV  MJKEY_PATH /workspace/.mujoco/mjkey.txt
# ENV  MJLIB_PATH /workspace/.mujoco/mujoco200_linux/bin/libmujoco200.so

ENV  LD_LIBRARY_PATH /workspace/.mujoco/mujoco200_linux/bin:$LD_LIBRARY_PATH
ENV  MUJOCO_PY_MJPRO_PATH /workspace/.mujoco/mujoco200_linux/
ENV  MUJOCO_PY_MUJOCO_PATH /workspace/.mujoco/mujoco200_linux/
ENV  MUJOCO_PY_MJKEY_PATH /workspace/.mujoco/mjkey.txt
ENV  MJKEY_PATH /workspace/.mujoco/mjkey.txt
ENV  MJLIB_PATH /workspace/.mujoco/mujoco200_linux/bin/libmujoco200.so


RUN   pip install pandas roboschool tensorflow==1.14
WORKDIR /opt
RUN git clone https://github.com/openai/baselines.git \
&& cd baselines \
&& pip install -e .




# RUN echo "export LD_LIBRARY_PATH=/workspace/.mujoco/mjpro150/bin:$LD_LIBRARY_PATH" >> /etc/profile
# RUN echo "export MUJOCO_PY_MJPRO_PATH=/workspace/.mujoco/mjpro150/" >> /etc/profile
# RUN echo "export MUJOCO_PY_MUJOCO_PATH=/workspace/.mujoco/mujoco200_linux/" >> /etc/profile
# RUN echo "export MJLIB_PATH=/workspace/.mujoco/mujoco200_linux/bin/libmujoco200.so" >> /etc/profile
# RUN echo "export MUJOCO_PY_MJKEY_PATH=/workspace/.mujoco/mjkey.txt" >> /etc/profile
# RUN echo "export MJKEY_PATH=/workspace/.mujoco/mjkey.txt" >> /etc/profile

RUN echo "export LD_LIBRARY_PATH=/workspace/.mujoco/mujoco200_linux/bin:$LD_LIBRARY_PATH" >> /etc/profile
RUN echo "export MUJOCO_PY_MJPRO_PATH=/workspace/.mujoco/mujoco200_linux/" >> /etc/profile
RUN echo "export MUJOCO_PY_MUJOCO_PATH=/workspace/.mujoco/mujoco200_linux/" >> /etc/profile
RUN echo "export MJLIB_PATH=/workspace/.mujoco/mujoco200_linux/bin/libmujoco200.so" >> /etc/profile
RUN echo "export MUJOCO_PY_MJKEY_PATH=/workspace/.mujoco/mjkey.txt" >> /etc/profile
RUN echo "export MJKEY_PATH=/workspace/.mujoco/mjkey.txt" >> /etc/profile



RUN pip install dm_control


# RUN export LD_LIBRARY_PATH=/workspace/.mujoco/mjpro150/bin:$LD_LIBRARY_PATH &&
RUN pip install mujoco-py==2.0.2.0
# RUN pip install mujoco-py==1.50.1.68
# RUN echo $LD_LIBRARY_PATH && echo $MJLIB_PATH
RUN   pip install git+https://github.com/aravindr93/mjrl.git
RUN   pip install git+https://github.com/xfdywy/d4rl.git
# && pip install git+https://github.com/takuseno/d4rl-pybullet && pip install pybullet


ENV PATH $PATH:/opt/conda/bin


RUN apt update && apt  install  -y --allow-change-held-packages --no-install-recommends \
        libglew-dev libglfw3-dev && \
         rm -rf /var/lib/apt/lists/*




#################self add end##########################


# RUN PATH=$PATH:/usr/local/lifli/openmpi/bin/ LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lifli/openmpi/lib/ HOROVOD_NCCL_HOME=/usr/local/lifli/nccl/ HOROVOD_NCCL_INCLUDE=/usr/local/lifli/nccl/include/ HOROVOD_NCCL_LIB=/usr/local/lifli/nccl/lib/ HOROVOD_WITH_MPI=1 HOROVOD_GPU_OPERATIONS=NCCL HOROVOD_GPU_ALLREDUCE=NCCL HOROVOD_WITH_PYTORCH=1
# RUN pip install --no-cache-dir horovod[pytorch]==0.19.5 && horovodrun --check-build

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

RUN wget https://roboti.us/file/mjkey.txt -O /workspace/.mujoco/mjkey.txt

# run the validation
RUN /opt/microsoft/_singularity/validations/validator.sh


RUN chmod -R 777 /workspace
RUN chmod -R 777 /opt 