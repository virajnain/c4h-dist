FROM almalinux:9

SHELL ["/bin/bash", "-c"]

RUN dnf -y update && \
    dnf install -y \
    git \
	gcc \
    gcc-c++ \
    gcc-gfortran \
    make \
	cmake \
    python3 \
    python3-pip \
    wget \
    tar \
	xz \
	bzip2 \
    which \
    file \
	patch \
    hostname \
    perl \
	procps-ng \
    openssl-devel \
    libuuid-devel \
    libX11-devel \
    libXpm-devel \
    libXft-devel \
    libXext-devel \
    mesa-libGL-devel \
    glibc-langpack-en \
    dnf-plugins-core && \
    dnf clean all

ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

WORKDIR /opt
RUN git clone --branch v1.0.0 https://github.com/spack/spack.git

# Fix readline patch URL (ftpmirror.gnu.org has been unreliable)
RUN source /opt/spack/share/spack/setup-env.sh && \
    sed -i 's#https://ftpmirror.gnu.org/readline#https://ftp.gnu.org/gnu/readline#g' \
    $(spack location -p readline)/package.py

RUN source /opt/spack/share/spack/setup-env.sh && \
    spack install gcc@14

RUN source /opt/spack/share/spack/setup-env.sh && \
    spack compiler find && \
    spack compiler list

COPY c4h-spack-packages /opt/c4h-spack-packages
COPY spack.yaml /opt/spack-env/spack.yaml

RUN source /opt/spack/share/spack/setup-env.sh && \
    spack repo add /opt/c4h-spack-packages/spack_repo/code4hep && \
    spack repo list

RUN source /opt/spack/share/spack/setup-env.sh && \
    spack env create code4hep_env /opt/spack-env/spack.yaml && \
    spack env activate code4hep_env && \
    spack concretize -f && \
    spack spec root && \
    spack install --fail-fast --show-log-on-error

WORKDIR /scratch
RUN git clone https://github.com/code4hep/build.git -b bootstrap

COPY patch-code4hep-install.sh /scratch/build/patch-code4hep-install.sh
WORKDIR /scratch/build
RUN chmod +x patch-code4hep-install.sh && ./patch-code4hep-install.sh

CMD ["bash"]
