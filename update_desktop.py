import os
import glob
import re

desktop_dir = "m:/TelcoChiselOS/builder/menu/applications"
files = glob.glob(os.path.join(desktop_dir, "*.desktop"))

for filepath in files:
    with open(filepath, 'r') as f:
        content = f.read()

    if 'xfce4-terminal' not in content:
        continue

    lines = content.split('\n')
    new_lines = []
    modified = False

    for line in lines:
        if line.startswith('Exec=xfce4-terminal'):
            # Extract the bash command part
            # Expected format: Exec=xfce4-terminal --hold [--title="..."] -x bash -c "..." or '...'
            # Let's use regex to find the bash -c content
            match = re.search(r'bash -c (["\'])(.*)\1', line)
            if match:
                quote = match.group(1)
                cmd = match.group(2)
                
                # Check if command has a read -p or read -rp
                if 'read -p' not in cmd and 'read -rp' not in cmd:
                    if cmd.endswith(';'):
                        cmd += ' exec bash'
                    else:
                        cmd += '; exec bash'
                
                new_line = f"Exec=gnome-terminal -- bash -c {quote}{cmd}{quote}"
                new_lines.append(new_line)
                modified = True
            else:
                # If it doesn't match the expected bash -c structure, log it
                print(f"WARN: Could not parse bash command in {filepath}: {line}")
                new_lines.append(line)
        else:
            new_lines.append(line)

    if modified:
        with open(filepath, 'w') as f:
            f.write('\n'.join(new_lines))
        print(f"Updated {filepath}")
