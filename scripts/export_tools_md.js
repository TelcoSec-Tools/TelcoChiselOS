const fs = require('fs');
const path = require('path');
const catalog = JSON.parse(fs.readFileSync(path.join(__dirname, '..', 'data', 'tools.json'), 'utf8'));

const catMap = {
  sdr: 'Software Defined Radio (SDR) & DSP',
  '2g': '2G / GSM Security',
  '4g': '4G LTE Security',
  '5g': '5G NR Security & Fuzzing',
  baseband: 'Baseband & UE Firmware Analysis',
  core: 'Core Signaling & Protocol Auditing',
  sim: 'SIM & eSIM Smartcard Auditing',
  voip: 'VoIP & SIP Security',
  mw: 'Telecom Middleware & OSS Management',
  adsl: 'Broadband, ADSL & DOCSIS / HFC Security'
};

const grouped = {};
for (const item of catalog) {
  const c = item.category || 'other';
  if (!grouped[c]) grouped[c] = [];
  grouped[c].push(item);
}

let md = '# TelcoChiselOS Default Tools Catalog\n\n';
md += `TelcoChiselOS includes **${catalog.length} default tools** organized across 10 specialized functional domains. Tools marked \`Ready\` are pre-configured and executable immediately. Tools marked \`Setup\` feature automated first-run helper scripts.\n\n`;

for (const [cat, name] of Object.entries(catMap)) {
  const tools = grouped[cat] || [];
  md += `## ${name} (${tools.length} tools)\n\n`;
  md += '| Tool Name | Status | Command / Executable | Description |\n';
  md += '| :--- | :---: | :--- | :--- |\n';
  for (const t of tools) {
    const status = t.status === 'ready' ? '`Ready`' : '`Setup`';
    md += `| **${t.name}** | ${status} | \`${t.cmd}\` | ${t.desc} |\n`;
  }
  md += '\n';
}

const targetPath = process.argv[2] || path.join(__dirname, '..', 'docs', 'data', 'tools_catalog.md');
fs.writeFileSync(targetPath, md, 'utf8');
console.log(`Tool catalog (${catalog.length} tools) written to ${targetPath}`);
