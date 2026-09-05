## Summary of Changes

<!-- Provide a concise description of what this PR introduces, modifies, or fixes. -->

- 

## Motivation & Context

<!-- Why is this change needed? Link related issue: Fixes #(issue) or Resolves #(issue). -->

- 

## Type of Change

- [ ] New Tool (added new telecom/SDR/baseband tool)
- [ ] Bug Fix (non-breaking change which fixes an issue)
- [ ] Enhancement / Performance (optimizations to build, kernel, or desktop)
- [ ] Documentation (updates to README, docs portal, or offline guide)
- [ ] CI/CD & Automation (workflows, scripts, or container configurations)

## Pre-Merge Quality Checklist

- [ ] **Bash Syntax Check**: Ran `wsl bash scripts/test_syntax.sh` (`bash -n` passes cleanly across all scripts).
- [ ] **Catalog Parity**: If a tool was added/modified, updated `data/tools.json` and ran `node scripts/sync-catalogs.js`.
- [ ] **Desktop Launcher**: Added `.desktop` entry in `builder/menu/applications/` (if GUI or interactive tool).
- [ ] **Hardware Permissions**: Added udev rules in `builder/scripts/08-system-optimization.sh` (if new hardware/SDR).
- [ ] **Line Endings**: Verified Unix LF line endings (`python scripts/fix_crlf.py --check`).
- [ ] **Tested in Live Environment**: Tested either via local build (`./build-wsl.sh --flavor=lite`) or QEMU boot test.

## Screenshots / Terminal Output (Optional)

<!-- Attach terminal outputs, screenshots, or logs demonstrating the change. -->
