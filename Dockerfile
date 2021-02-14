FROM debian:stable-slim AS qemu-builder
ARG QEMU_VERSION=4.2.0
ARG QEMU_TARBALL="v${QEMU_VERSION}.tar.gz"
WORKDIR /qemu

# Update package lists
RUN apt-get update

# Pull source
#RUN apt-get -y install wget
#RUN wget "https://github.com/igwtech/qemu/archive/${QEMU_TARBALL}"
RUN apt-get -y install git
RUN git clone https://github.com/igwtech/qemu.git && \
    cd qemu && \
    git submodule init && \
    git submodule update --recursive

## Extract source tarball
#RUN apt-get -y install pkg-config
#RUN tar xvf "${QEMU_TARBALL}"
#
# Build source
# These seem to be the only deps actually required for a successful  build
RUN apt-get -y install python build-essential libglib2.0-dev libpixman-1-dev
# These don't seem to be required but are specified here: https://wiki.qemu.org/Hosts/Linux
RUN apt-get -y install libfdt-dev zlib1g-dev
# Not required or specified anywhere but supress build warnings
RUN apt-get -y install flex bison
RUN ./qemu/configure --static --target-list=arm-softmmu,aarch64-softmmu
RUN make -j$(nproc)
#
#RUN # Strip the binary, this gives a substantial size reduction!
#RUN strip "arm-softmmu/qemu-system-arm" "aarch64-softmmu/qemu-system-aarch64"
