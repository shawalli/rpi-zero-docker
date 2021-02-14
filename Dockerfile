#######################################
# BUILDER: qemu
#######################################
FROM debian:stable-slim AS qemu-builder
ARG QEMU_VERSION=v4.2.0
ARG QEMU_PACKAGES="""\
    git \
    python \
    build-essential \
    libglib2.0-dev \
    libpixman-1-dev \
    libfdt-dev \
    zlib1g-dev \
    flex \
    bison \
"""

WORKDIR /qemu

#### Update package lists
RUN apt-get update

#### Install dependencies
RUN apt-get -y install ${QEMU_PACKAGES}

#### Clone source
RUN git clone https://github.com/igwtech/qemu.git 
RUN cd qemu && \
    git checkout ${QEMU_VERSION} && \
    git submodule init && \
    git submodule update --recursive

#### Build qemu
RUN ./qemu/configure --static --target-list=arm-softmmu,aarch64-softmmu
RUN make -j$(nproc)

#### Strip the binary, this gives a substantial size reduction!
RUN strip "arm-softmmu/qemu-system-arm" "aarch64-softmmu/qemu-system-aarch64"
