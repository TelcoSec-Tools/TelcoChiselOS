# syntax=docker/dockerfile:1
# =============================================================================
# telcochisel-base — headless CLI toolset (protocol scanners, SS7/Diameter/GTP
# exploitation, baseband/SIM analysis, 5G UE/gNB simulation).
#
# Build context is the REPO ROOT (not docker/) so this Dockerfile can COPY
# builder/scripts/lib/* — the single source of truth for package lists —
# without duplicating those files. Run from the repo root:
#
#   docker build -f docker/base.Dockerfile -t telcochisel-base .
#
# See docker/README.md for the full reuse boundary and what's deliberately
# left out of this image (GUI desktop, kernel modules, systemd services —
# those belong to the ISO or to the sdr/core-network/device-tools add-ons).
# =============================================================================
FROM ubuntu:24.04

LABEL org.opencontainers.image.title="telcochisel-base" \
      org.opencontainers.image.description="TelcoChisel headless CLI telecom security toolset" \
      org.opencontainers.image.source="https://github.com/TelcoSec-Tools/TelcoChiselOS"

ENV DEBIAN_FRONTEND=noninteractive \
    TELCOSEC_OPT=/opt/telcosec \
    PATH="/usr/local/bin:${PATH}"

# telcosec user — parity with the ISO's account so tool configs, wordlist
# paths, and /opt/telcosec ownership match what TelcoChisel documentation
# and helper scripts already assume. ubuntu:24.04 ships a pre-existing
# "ubuntu" user/group at uid/gid 1000 (since 24.04's image revamp) — remove
# it first so telcosec can claim 1000:1000 cleanly.
RUN (getent passwd ubuntu >/dev/null && userdel -r ubuntu 2>/dev/null || true) \
 && (getent group ubuntu >/dev/null && groupdel ubuntu 2>/dev/null || true) \
 && groupadd -g 1000 telcosec \
 && useradd -u 1000 -g telcosec -m -s /bin/bash telcosec \
 && mkdir -p /opt/telcosec/lib && chown -R telcosec:telcosec /opt/telcosec

COPY builder/scripts/lib/packages.sh         /opt/telcosec/lib/packages.sh
COPY builder/scripts/lib/pip-retry.sh        /opt/telcosec/lib/pip-retry.sh
COPY builder/scripts/lib/pip-constraints.txt /opt/telcosec/lib/pip-constraints.txt
COPY builder/scripts/lib/record-tool.sh      /opt/telcosec/lib/record-tool.sh
COPY builder/wordlists/                      /opt/telcosec/wordlists/
COPY docker/scripts/00-container-common.sh   /opt/telcosec/lib/00-container-common.sh
COPY docker/scripts/10-base-tools.sh         /tmp/10-base-tools.sh

RUN bash /tmp/10-base-tools.sh && rm -f /tmp/10-base-tools.sh

WORKDIR /home/telcosec
USER telcosec
CMD ["/bin/bash"]
