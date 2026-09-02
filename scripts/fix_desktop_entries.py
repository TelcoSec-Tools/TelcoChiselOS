#!/usr/bin/env python3
import os

fixes = {
    '5ghoul-bladerf.desktop': 'Exec=x-terminal-emulator -e "bash -c \'sudo 5ghoul-install --radio BLADERF; echo; read -rp \\"Press Enter to close...\\"\'"',
    '5ghoul-fuzzer.desktop': 'Exec=x-terminal-emulator -e "bash -c \'sudo 5ghoul-run; read -rp \\"Press Enter to close...\\"\'"',
    '5ghoul-install.desktop': 'Exec=x-terminal-emulator -e "bash -c \'sudo 5ghoul-install; echo; read -rp \\"Press Enter to close...\\"\'"',
    'adb-devices.desktop': 'Exec=x-terminal-emulator -e "bash -c \'adb devices -l; exec bash\'"',
    'adb-shell.desktop': 'Exec=x-terminal-emulator -e "bash -c \'adb shell; exec bash\'"',
    'diafuzzer.desktop': 'Exec=x-terminal-emulator -e "bash -c \'python3 /opt/telcosec/diafuzzer/dia_fuzzer.py --help; read -p \\"Press enter to exit...\\"\'"',
    'edl.desktop': 'Exec=x-terminal-emulator -e "bash -c \'edl --help; exec bash\'"',
    'ericsson-enm-cli.desktop': 'Exec=x-terminal-emulator -e "bash -c \'ericsson-enm-cli; echo \\"\\"; read -p \\"Press Enter to exit...\\"\'"',
    'firmwire.desktop': 'Exec=x-terminal-emulator -e "bash -c \'source /opt/telcosec/firmwire/venv/bin/activate && python3 /opt/telcosec/firmwire/firmwire.py --help; read -p \\"Press enter to exit...\\"\'"',
    'gammu-sms.desktop': 'Exec=x-terminal-emulator -e "bash -c \'gammu --help; exec bash\'"',
    'grgsm-scanner.desktop': 'Exec=x-terminal-emulator -e "bash -c \'grgsm_scanner --help; echo \\"\\"; read -p \\"Press Enter to exit...\\"\'"',
    'gtp5g-load.desktop': 'Exec=x-terminal-emulator -e "bash -c \'sudo gtp5g-load; exec bash\'"',
    'heimdall.desktop': 'Exec=x-terminal-emulator -e "bash -c \'heimdall --help; exec bash\'"',
    'huawei-u2000-cli.desktop': 'Exec=x-terminal-emulator -e "bash -c \'huawei-u2000-cli; echo \\"\\"; read -p \\"Press Enter to exit...\\"\'"',
    'kalibrate-gsm.desktop': 'Exec=x-terminal-emulator -e "bash -c \'kal-gsm -h; exec bash\'"',
    'kalibrate-rtl.desktop': 'Exec=x-terminal-emulator -e "bash -c \'kal -h; echo \\"\\"; read -p \\"Press Enter to exit...\\"\'"',
    'kismet.desktop': 'Exec=x-terminal-emulator -e "bash -c \'sudo kismet -c mon0; exec bash\'"',
    'lpac.desktop': 'Exec=x-terminal-emulator -e "bash -c \'lpac --help; read -p \\"Press Enter to exit...\\"\'"',
    'lte-cellscanner.desktop': 'Exec=x-terminal-emulator -e "bash -c \'LTE-CellSearch --help; exec bash\'"',
    'ltesniffer.desktop': 'Exec=x-terminal-emulator -e "bash -c \'ltesniffer --help; exec bash\'"',
    'minicom-at.desktop': 'Exec=x-terminal-emulator -e "bash -c \'at-console; exec bash\'"',
    'modmobmap.desktop': 'Exec=x-terminal-emulator -e "bash -c \'modmobmap --help; exec bash\'"',
    'nokia-netact-cli.desktop': 'Exec=x-terminal-emulator -e "bash -c \'nokia-netact-cli; echo \\"\\"; read -p \\"Press Enter to exit...\\"\'"',
    'oai-install.desktop': 'Exec=x-terminal-emulator -e "bash -c \'sudo oai-install; exec bash\'"',
    'open5gs-start.desktop': 'Exec=x-terminal-emulator -e "bash -c \'sudo open5gs-start; read -rp \\"Press Enter to close...\\"\'"',
    'openbts-install.desktop': 'Exec=x-terminal-emulator -e "bash -c \'sudo openbts-install; exec bash\'"',
    'pysim-shell.desktop': 'Exec=x-terminal-emulator -e "bash -c \'pySim-shell --help; read -p \\"Press enter to exit...\\"\'"',
    'qcsuper.desktop': 'Exec=x-terminal-emulator -e "bash -c \'qcsuper --help; read -p \\"Press enter to exit...\\"\'"',
    'scat.desktop': 'Exec=x-terminal-emulator -e "bash -c \'scat -t qc -d /dev/ttyUSB0; exec bash\'"',
    'sigploit.desktop': 'Exec=x-terminal-emulator -e "bash -c \'cd /opt/telcosec/sigploit && PYTHONPATH=/opt/telcosec/sigploit:/opt/telcosec/sigploit/gtp /opt/telcosec/python2/bin/python2.7 sigploit.py; read -p \\"Press enter to exit...\\"\'"',
    'simtester.desktop': 'Exec=x-terminal-emulator -e "bash -c \'simtester; exec bash\'"',
    'simtrace2-sniff.desktop': 'Exec=x-terminal-emulator -e "bash -c \'simtrace2-sniff --help; read -p \\"Press enter to exit...\\"\'"',
    'simurai.desktop': 'Exec=x-terminal-emulator -e "bash -c \'simurai; echo \\"\\"; read -p \\"Press Enter to exit...\\"\'"',
    'sipp.desktop': 'Exec=x-terminal-emulator -e "bash -c \'sipp -h; exec bash\'"',
    'srsran-install.desktop': 'Exec=x-terminal-emulator -e "bash -c \'sudo srsran-install; read -p \\"Press Enter to exit...\\"\'"',
    'srsue.desktop': 'Exec=x-terminal-emulator -e "bash -c \'srsue; exec bash\'"',
    'tcpdump.desktop': 'Exec=x-terminal-emulator -e "bash -c \'sudo tcpdump -i mon0 -v; exec bash\'"',
    'telcosec-apn-permutator.desktop': 'Exec=x-terminal-emulator -e "bash -c \'telcosec-apn-permutator --help; echo; read -rp \\"Press Enter to close...\\"\'"',
    'telcosec-imsi-generator.desktop': 'Exec=x-terminal-emulator -e "bash -c \'telcosec-imsi-generator --help; echo; read -rp \\"Press Enter to close...\\"\'"',
    'telcosec-profile.desktop': 'Exec=x-terminal-emulator -e "bash -c \'sudo telcosec-profile status; echo \\"\\"; echo \\"Commands: sudo telcosec-profile set [lab|field]\\"; read -rp \\"Press Enter to close...\\"\'"',
    'telcosec-docs.desktop': 'Exec=firefox file:///usr/share/doc/telcosec/index.html',
    'ueransim-gnb.desktop': 'Exec=x-terminal-emulator -e "bash -c \'sudo nr-gnb -c /etc/telcosec/ueransim/gnb.yaml; exec bash\'"',
    'ueransim-ue.desktop': 'Exec=x-terminal-emulator -e "bash -c \'nr-ue -c /etc/telcosec/ueransim/ue.yaml; exec bash\'"',
    'yatebts-run.desktop': 'Exec=x-terminal-emulator -e "bash -c \'sudo yate -s -l /var/log/yate.log; exec bash\'"',
    'yatebts.desktop': 'Exec=x-terminal-emulator -e "bash -c \'sudo yatebts-install; exec bash\'"',
}

repo_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
apps_dir = os.path.join(repo_root, 'builder', 'menu', 'applications')

count = 0
for filename, new_exec in fixes.items():
    filepath = os.path.join(apps_dir, filename)
    if not os.path.exists(filepath):
        print(f'Warning: {filename} does not exist at {filepath}')
        continue
    with open(filepath, 'r', encoding='utf-8') as f:
        lines = f.readlines()
    
    new_lines = []
    for line in lines:
        if line.startswith('Exec='):
            new_lines.append(new_exec + '\n')
        else:
            new_lines.append(line)
            
    with open(filepath, 'w', encoding='utf-8', newline='\n') as f:
        f.writelines(new_lines)
    count += 1

print(f'Successfully updated {count} .desktop files.')
