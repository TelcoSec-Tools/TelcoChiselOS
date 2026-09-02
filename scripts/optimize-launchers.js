#!/usr/bin/env node

/**
 * optimize-launchers.js
 * Standardizes desktop launcher files in builder/menu/applications/
 * Replaces hardcoded gnome-terminal references with x-terminal-emulator for
 * seamless OS terminal integration (Terminator).
 */

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

const pythonScript = path.join(__dirname, 'fix_desktop_entries.py');
if (fs.existsSync(pythonScript)) {
    try {
        const output = execSync(`python "${pythonScript}"`, { encoding: 'utf8' });
        console.log(output.trim());
    } catch (e) {
        console.error('Failed to run fix_desktop_entries.py:', e);
    }
}

