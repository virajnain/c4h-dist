ARG BASE_IMAGE=ghcr.io/virajnain/c4h-base:latest
FROM ${BASE_IMAGE}

SHELL ["/bin/bash", "-c"]

WORKDIR /opt
RUN git clone --branch v1.0.0 https://github.com/spack/spack.git

# Pull prebuilt packages from the build cache when available
ARG C4H_CACHE_URL=oci://ghcr.io/virajnain/c4h-buildcache
RUN source /opt/spack/share/spack/setup-env.sh && \
    spack mirror add --unsigned c4h ${C4H_CACHE_URL}

RUN source /opt/spack/share/spack/setup-env.sh && \
    spack compiler find

RUN source /opt/spack/share/spack/setup-env.sh && \
    spack install gcc@14 && \
    spack compiler find && \
    spack compiler list

ARG C4H_SPACK_PACKAGES_REPO=https://github.com/virajnain/c4h-spack-packages.git
ARG C4H_SPACK_PACKAGES_REF=main
RUN git clone ${C4H_SPACK_PACKAGES_REPO} /opt/c4h-spack-packages && \
    git -C /opt/c4h-spack-packages checkout ${C4H_SPACK_PACKAGES_REF}

RUN source /opt/spack/share/spack/setup-env.sh && \
    spack repo add /opt/c4h-spack-packages/spack_repo/code4hep && \
    spack repo list

COPY spack.yaml /opt/spack-env/spack.yaml

ARG SPACK_JOBS=4
RUN source /opt/spack/share/spack/setup-env.sh && \
    spack env create code4hep_env /opt/spack-env/spack.yaml && \
    spack env activate code4hep_env && \
    spack concretize -f && \
    spack install --fail-fast --show-log-on-error -j${SPACK_JOBS} && \
    spack clean --downloads

COPY scripts/c4h-develop /usr/local/bin/c4h-develop
RUN chmod +x /usr/local/bin/c4h-develop

CMD ["bash"]