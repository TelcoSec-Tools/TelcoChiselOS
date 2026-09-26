#!/usr/bin/env python3
"""
SourceForge Git Non-Fast-Forward Unlocker
Connects to SourceForge shell service to disable receive.denyNonFastForwards
when repository history has been rewritten (e.g. metadata/trailer cleanup).
"""

import sys
import time

def main():
    if len(sys.argv) < 4:
        print("Usage: sf_allow_force_push.py <SF_USER> <SF_PROJECT> <SSH_KEY_PATH>")
        sys.exit(1)

    sf_user = sys.argv[1]
    sf_project = sys.argv[2]
    ssh_key_path = sys.argv[3]

    try:
        import pexpect
    except ImportError:
        print("Error: pexpect is required. Run 'pip install pexpect'.")
        sys.exit(1)

    cmd = (
        f"ssh -tt -i {ssh_key_path} "
        f"-o BatchMode=yes -o StrictHostKeyChecking=accept-new "
        f"{sf_user},{sf_project}@shell.sourceforge.net create"
    )
    print(f"Connecting to SourceForge shell for {sf_user},{sf_project}...")

    try:
        child = pexpect.spawn(cmd, encoding="utf-8", timeout=60)
        child.logfile_read = sys.stdout

        # Wait for shell prompt ($ or #)
        child.expect([r"[\$#]"], timeout=45)
        print("\n[+] SourceForge interactive shell ready.")

        # Unlock both potential mount paths
        unlock_cmd = (
            f"for d in /home/git/p/{sf_project}/code.git /git/p/{sf_project}/code.git; do "
            f'if [ -d "$d" ]; then '
            f'git --git-dir="$d" config receive.denyNonFastForwards false && echo "[+] UNLOCKED: $d"; '
            f"fi; done"
        )
        child.sendline(unlock_cmd)
        child.expect([r"[\$#]"], timeout=15)

        # Terminate shell cleanly
        child.sendline("shutdown")
        try:
            child.expect(pexpect.EOF, timeout=15)
        except Exception:
            pass
        print("\n[+] SourceForge shell configuration complete.")

    except Exception as e:
        print(f"\n[-] Failed to configure SourceForge repository via shell: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
