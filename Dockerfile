FROM ubuntu:22.04 as builder

#System packages needed by Spack
RUN apt-get update && apt-get install -y \
    bash \
    git \
    curl \
    wget \
    unzip \
    xz-utils \
    bzip2 \
    file \
    patch \
    make \
    python3 \
    build-essential \
    gfortran \
    ca-certificates \
    ninja-build \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt

#Install Spack
RUN git clone --branch v1.0.0 https://github.com/spack/spack.git

SHELL ["/bin/bash", "-c"]

#Add compiler
RUN source /opt/spack/share/spack/setup-env.sh && \
    spack compiler find && \
    spack install gcc@14 && \
    spack compiler add $(spack location -i gcc@14)

COPY c4h-spack-packages /opt/c4h-spack-packages

#Create Spack environment
RUN source /opt/spack/share/spack/setup-env.sh && \
    spack env create code4hep_env

#Install Code4hep
RUN source /opt/spack/share/spack/setup-env.sh && \
    spack env activate code4hep_env && \
    spack repo add /opt/c4h-spack-packages/spack_repo/code4hep && \
    spack add code4hep %gcc@14 && \
    spack concretize -f && \
    spack install

CMD ["/bin/bash"]

#Deployment stage
FROM ubuntu:22.04 as final

RUN apt-get update && apt-get install -y \
    bash \
    git \
    curl \
    wget \
    unzip \
    xz-utils \
    bzip2 \
    file \
    patch \
    make \
    python3 \
    build-essential \
    gfortran \
    ca-certificates \
    ninja-build \
    && rm -rf /var/lib/apt/lists/*

#Copy from build stage
COPY --from=builder /opt/spack/ /opt/spack/
COPY --from=builder /opt/c4h-spack-packages /opt/c4h-spack-packages

CMD ["bash"]