#!/usr/bin/env node

/**
 * optimize-launchers.js
 * Standardizes desktop launcher files in builder/menu/applications/
 * Replaces hardcoded gnome-terminal references with x-terminal-emulator for
 * seamless OS terminal integration (Terminator).
 */

const fs = require('fs');
const path = require('path');

const appsDir = path.join(__dirname, '..', 'builder', 'menu', 'applications');
const files = fs.readdirSync(appsDir).filter(f => f.endsWith('.desktop'));

let updatedCount = 0;

files.forEach(file => {
    const filePath = path.join(appsDir, file);
    let content = fs.readFileSync(filePath, 'utf8');

    if (content.includes('gnome-terminal -- bash -c')) {
        content = content.replace(/gnome-terminal -- bash -c/g, 'x-terminal-emulator -e "bash -c');
        // Ensure closing quote is matched if needed
        if (content.match(/Exec=x-terminal-emulator -e "bash -c [^"\n]+$/m)) {
            content = content.replace(/(Exec=x-terminal-emulator -e "bash -c [^\n]+)$/m, '$1"');
        }
        fs.writeFileSync(filePath, content, 'utf8');
        console.log(`Updated ${file}: replaced gnome-terminal with x-terminal-emulator`);
        updatedCount++;
    }
});

console.log(`\nSuccessfully updated ${updatedCount} launcher files.`);
