#!/bin/bash
# runs inside the c4h-base image
set -uo pipefail
S=/opt/spack/bin/spack
JOBS=${JOBS:-4}; BUDGET=${BUDGET:-19200}   # build for 5h20m, leave time to push

git clone --branch v1.0.0 https://github.com/spack/spack.git /opt/spack
git clone "$PKGS_REPO" /opt/c4h-spack-packages && git -C /opt/c4h-spack-packages checkout "$PKGS_REF"
$S repo add /opt/c4h-spack-packages/spack_repo/code4hep
$S mirror add --unsigned --oci-username "$GHCR_USER" --oci-password-variable GHCR_TOKEN c4h "$CACHE_URL"
$S compiler find
$S env create code4hep_env spack.yaml

timeout -s INT "$BUDGET" bash -c "$S install gcc@14 && $S compiler find && \
  $S -e code4hep_env concretize -f && $S -e code4hep_env install --fail-fast -j$JOBS"
STATUS=$?
$S buildcache push --unsigned --update-index c4h $($S find --format '/{hash}')
exit $STATUS    # 0 finished, 124 ran out of time, anything else = a real failure