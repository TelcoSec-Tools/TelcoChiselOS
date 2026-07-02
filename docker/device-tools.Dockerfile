# syntax=docker/dockerfile:1
# =============================================================================
# telcochisel-device-tools — USB/serial device flashing & diagnostic wrappers
# (Heimdall, ADB/Fastboot, MTKClient, QCSuper, EDL, AT console).
#
# Build context is the REPO ROOT. Build from telcochisel-base — build that
# image first, or let buildx resolve it if pushed to a registry:
#
#   docker build -f docker/device-tools.Dockerfile -t telcochisel-device-tools .
#
# Needs --device /dev/bus/usb and/or /dev/ttyUSB*/ttyACM* at `docker run`
# time to actually reach hardware — see docker/README.md.
# =============================================================================
# See docker/sdr.Dockerfile's ARG BASE_IMAGE comment for why this is
# parameterized (buildx CI resolution vs. local `docker build`).
ARG BASE_IMAGE=telcochisel-base
FROM ${BASE_IMAGE}

LABEL org.opencontainers.image.title="telcochisel-device-tools" \
      org.opencontainers.image.description="TelcoChisel USB/serial device flashing & diagnostic tools" \
      org.opencontainers.image.source="https://github.com/TelcoSec-Tools/TelcoChiselOS"

USER root
COPY docker/scripts/40-device-tools.sh /tmp/40-device-tools.sh
RUN bash /tmp/40-device-tools.sh && rm -f /tmp/40-device-tools.sh

WORKDIR /home/telcosec
USER telcosec
CMD ["/bin/bash"]
