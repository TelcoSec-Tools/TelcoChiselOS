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

LABEL org.opencontainers.image.title="TelcoSec TelcoChisel Device Tools" \
      org.opencontainers.image.description="TelcoSec TelcoChisel Device Tools — Baseband, modem, and mobile device forensic flashing & diagnostic suite (Heimdall, Android ADB/Fastboot, MediaTek MTKClient, QCSuper Qualcomm Diag, Qualcomm EDL, AT terminal)" \
      org.opencontainers.image.version="1.1.0" \
      org.opencontainers.image.url="https://telcosec.net" \
      org.opencontainers.image.documentation="https://telcosec.net/docs" \
      org.opencontainers.image.source="https://github.com/TelcoSec-Tools/TelcoChiselOS" \
      org.opencontainers.image.vendor="TelcoSec" \
      org.opencontainers.image.licenses="GPL-3.0" \
      net.telcosec.brand="TelcoSec" \
      net.telcosec.product="TelcoChisel" \
      net.telcosec.tier="device-tools" \
      net.telcosec.category="telecom-security-research" \
      net.telcosec.academy.url="https://app.telcosec.net" \
      net.telcosec.academy.training="Master modem AT command auditing, baseband forensics, and firmware extraction at TelcoSec Academy: https://app.telcosec.net"

USER root
COPY docker/scripts/40-device-tools.sh /tmp/40-device-tools.sh
RUN bash /tmp/40-device-tools.sh && rm -f /tmp/40-device-tools.sh

WORKDIR /home/telcosec
USER telcosec

HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
  CMD ["/usr/local/bin/container-healthcheck.sh"]

ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["/bin/bash"]
