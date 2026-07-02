# syntax=docker/dockerfile:1
# =============================================================================
# telcochisel-core-network — srsRAN/Open5GS/OAI-UE/5Ghoul first-run helper
# stubs, with their build-dependency sets prebaked so the actual first-run
# compiles (triggered by the user, on the live container) are fast.
#
# Build context is the REPO ROOT. Build from telcochisel-base:
#
#   docker build -f docker/core-network.Dockerfile -t telcochisel-core-network .
#
# Needs --cap-add=NET_ADMIN, /dev/net/tun, and usually --network host at
# `docker run` time for RAN/core networking. gtp5g (a kernel module) and
# Open5GS (upstream docker-compose flow) have real limitations in a
# container — see docker/README.md "Known limitations" before relying on
# either from inside this image.
# =============================================================================
# See docker/sdr.Dockerfile's ARG BASE_IMAGE comment for why this is
# parameterized (buildx CI resolution vs. local `docker build`).
ARG BASE_IMAGE=telcochisel-base
FROM ${BASE_IMAGE}

LABEL org.opencontainers.image.title="telcochisel-core-network" \
      org.opencontainers.image.description="TelcoChisel core-network first-run helpers (srsRAN/Open5GS/OAI-UE/5Ghoul)" \
      org.opencontainers.image.source="https://github.com/TelcoSec-Tools/TelcoChiselOS"

USER root
COPY docker/scripts/30-core-network.sh /tmp/30-core-network.sh
RUN bash /tmp/30-core-network.sh && rm -f /tmp/30-core-network.sh

WORKDIR /home/telcosec
USER telcosec
CMD ["/bin/bash"]
