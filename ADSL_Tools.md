1. Network Sniffing & Manipulation
wireshark-cli / tshark: Essential for analyzing PCAP files to extract CWMP XML payloads, PPPoE challenge/response hashes, and SIP SIP/RTP packets.
tcpdump: Standard command-line packet analyzer.
scapy: Python library for crafting custom L2/L3 packets (e.g., forging PPPoE Discovery PADI packets to spoof the Access Concentrator).
macchanger: For spoofing MAC addresses to bypass sticky-MAC port security on the DSLAM.
vlan (vconfig): To execute VLAN hopping attacks against the DSLAM's Open vSwitch configuration.
2. PPPoE & RADIUS Exploitation
asleap: Used to perform offline dictionary attacks against captured PPPoE MS-CHAPv2 challenge/response hashes.
freeradius-utils (radtest, radclient): To craft malicious RADIUS Access-Request packets or test dictionary attacks directly against the AAA server.
hashcat or john: Essential for cracking the intercepted RADIUS shared secrets or MS-CHAPv2 hashes.
ppp & rp-pppoe: Required to establish rogue PPPoE sessions (acting as a rogue CPE).
3. Web & TR-069 (CWMP) Attacks
routersploit: The de-facto exploitation framework for embedded devices. Perfect for attacking the simulated Web UIs of the CPEs.
curl & wget: Fundamental for interacting with the GenieACS REST API.
nmap: For discovering the management IP addresses (e.g., scanning the 192.168.1.0/24 subnet to locate the ACS server, BNG, and DSLAM).
nikto / gobuster: For directory enumeration against the CPE's local Web UI or the GenieACS dashboard.
4. Generic Telecom Protocols
sipvicious: If VoIP is introduced, this is vital for scanning and attacking SIP PBXs over the broadband connection.
snmpwalk / snmp-check: To exploit the intentionally weak public/private community strings on our DSLAM to map the internal routing tables.