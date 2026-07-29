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
    dnf-plugins-core && \
    dnf clean all

WORKDIR /opt
RUN git clone --branch v1.0.0 https://github.com/spack/spack.git

RUN source /opt/spack/share/spack/setup-env.sh && \
    spack compiler find

RUN source /opt/spack/share/spack/setup-env.sh && \
    spack install gcc@14 && \
    spack compiler find $(spack location -i gcc@14)/bin && \
    spack compiler list

COPY c4h-spack-packages /opt/c4h-spack-packages

COPY spack.yaml /opt/spack-env/spack.yaml

RUN source /opt/spack/share/spack/setup-env.sh && \
    spack env create code4hep_env /opt/spack-env/spack.yaml && \
    spack env activate code4hep_env && \
    spack concretize -f && \
    spack spec root && \
    spack install --fail-fast --show-log-on-error

# Now bootstrap build
WORKDIR /scratch
RUN git clone https://github.com/code4hep/build.git -b bootstrap

WORKDIR /scratch/build
RUN source /opt/spack/share/spack/setup-env.sh && \
    spack env activate code4hep_env && \
    ./setup.sh

CMD ["bash"]