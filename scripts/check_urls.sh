#!/bin/bash
for url in \
  https://github.com/bkerler/gr-gsm \
  https://github.com/forth32/balongflash \
  https://github.com/forth32/balong-nvtool \
  https://github.com/steve-m/kalibrate-gsm \
  https://github.com/S3cur1ty-fr/modmobmap \
  https://github.com/srsran/srsgui \
  https://github.com/Evrytania/LTE-Cell-Scanner \
  https://github.com/SysSec-KAIST/LTESniffer \
  https://github.com/TelcoSec-Tools/RDNSx \
  https://github.com/joswr1ght/asleap \
  https://github.com/fkie-cad/falcon \
  https://github.com/da-luce/atinout
do
  echo -n "$url: "
  curl -I -s "$url" | head -n 1
done
