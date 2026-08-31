const fs = require('fs');
const path = require('path');
const catalog = JSON.parse(fs.readFileSync(path.join(__dirname, '..', 'data', 'tools.json'), 'utf8'));

console.log(`=== TelcoChisel Tool Integration & Command Validation ===`);
console.log(`Total tools in catalog: ${catalog.length}\n`);

const missingWrappers = [];

catalog.forEach((tool, index) => {
    const cmd = tool.cmd;
    const name = tool.name;
    const category = tool.category;
    
    // Extract primary binary or script invoked
    let mainBin = '';
    if (cmd.startsWith('sudo ')) {
        mainBin = cmd.split(' ')[1];
    } else if (cmd.includes('&&')) {
        mainBin = cmd.split('&&')[1].trim().split(' ')[0];
    } else {
        mainBin = cmd.split(' ')[0];
    }

    console.log(`[${(index + 1).toString().padStart(2, '0')}] ${name.padEnd(30)} | Cmd: ${cmd.padEnd(45)} | Bin: ${mainBin}`);
});
