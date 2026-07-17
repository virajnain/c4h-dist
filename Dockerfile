FROM ubuntu:22.04 AS builder

RUN apt-get update && apt-get install -y \
    bash git curl wget unzip xz-utils bzip2 file patch make \
    python3 build-essential gfortran ca-certificates ninja-build \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt
RUN git clone --branch v1.0.0 https://github.com/spack/spack.git

SHELL ["/bin/bash", "-c"]

RUN source /opt/spack/share/spack/setup-env.sh && \
    spack compiler find && \
    spack install gcc@14

COPY c4h-spack-packages /opt/c4h-spack-packages

RUN source /opt/spack/share/spack/setup-env.sh && \
    spack env create code4hep_env && \
    spack env activate code4hep_env && \
    spack config add "config:install_tree:root:/opt/software" && \
    spack config add "view:/opt/view"

RUN source /opt/spack/share/spack/setup-env.sh && \
    spack env activate code4hep_env && \
    spack repo add /opt/c4h-spack-packages/spack_repo/code4hep && \
    spack add code4hep %gcc@14 && \
    spack concretize -f && \
    spack install --fail-fast && \
    spack gc -y                       # <- drops build-only deps (cmake, m4, ...)

RUN find -L /opt/view/* -type f -exec readlink -f '{}' \; | \
    xargs file -i | grep 'charset=binary' | \
    grep 'x-executable\|x-archive\|x-sharedlib' | \
    awk -F: '{print $1}' | xargs strip 2>/dev/null || true

RUN source /opt/spack/share/spack/setup-env.sh && \
    spack env activate --sh -d /opt/spack/var/spack/environments/code4hep_env > /opt/activate.sh

FROM ubuntu:22.04 AS final

RUN apt-get update && apt-get install -y \
    bash git curl wget unzip xz-utils bzip2 file patch make \
    python3 build-essential gfortran ca-certificates ninja-build \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /opt/software /opt/software
COPY --from=builder /opt/view /opt/view
COPY --from=builder /opt/activate.sh /opt/activate.sh

RUN echo '. /opt/activate.sh' >> /etc/bash.bashrc
CMD ["bash"]
