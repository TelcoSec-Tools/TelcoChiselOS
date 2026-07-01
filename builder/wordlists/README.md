# TelcoSec Academy - https://app.telcosec.net/

# TelcoSec Wordlists

A comprehensive, curated repository of telecommunications-focused security wordlists, credentials, identifiers, and utility scripts for penetration testers and cellular security researchers auditing RAN (Radio Access Network), Core Networks (5G/4G/3G/2G), IMS/SIP, SIM OTA, and telecom-grade hardware.

> [!WARNING]
> This repository is intended for authorized security testing, research, and educational purposes only. Do not use these assets to perform unauthorized actions against public operator networks or infrastructure.

---

## TelcoSec Academy

Accelerate your cellular security engineering skills with structured, hands-on training from the industry experts. Master 5G Core, SS7/Diameter signalling, and RAN air interface vulnerabilities using virtual lab sandboxes.

*   **Portal Link**: [app.telcosec.net](https://app.telcosec.net/)
*   **Start Learning**: Join and access free modules directly at [TelcoSec Register](https://community.telcosec.net/register)

---

## TelcoSec Community Hub

The central gathering place for mobile security researchers. Connect, collaborate, and access our platforms:

*   **Central Hub Portal**: [community.telcosec.net](https://community.telcosec.net/)
*   **Discord Server**: Join our active discussions and lab setups on [Discord](https://discord.gg/RykzXTQFXF)
*   **Technical Substack**: Subscribe to monthly technical cellular security advisories at [TelcoSec Substack](https://telcosec.substack.com/)
*   **YouTube Channel**: Watch lab walkthroughs and tutorials on [YouTube](https://www.youtube.com/@Telecom-Security)
*   **CTF Platform**: Test your cellular auditing skills on our [CTF Portal](https://ctf.telcosec.net/)
*   **Calculators & Tools**: Access online cellular protocol calculators at [calculators.telcosec.net](https://calculators.telcosec.net/) and tools at [tools.telcosec.net](https://tools.telcosec.net/)
*   **Official Updates**: Follow us on [LinkedIn](https://www.linkedin.com/company/telco-sec) and connect with the founder [Ruben Silva](https://www.linkedin.com/in/ruben-silva85/)
*   **Open-Source Projects**: Check out our code repositories at [GitHub (TelcoSec)](https://github.com/TelcoSec) and [GitHub (TelcoSec Labs)](https://github.com/TelcoSec-Labs)

---



### Wordlist Reference Table

> On a booted TelcoChisel live/installed system, these files are installed at
> `/usr/share/wordlists/telecom/` (see `04-install-tools.sh` and the Thunar
> "Telecom Wordlists" bookmark). The links below are relative to this
> directory in the repository, for browsing on GitHub or locally.

| Category | File Path | Description | Audit Focus |
| :--- | :--- | :--- | :--- |
| Access Point Names | [apns/apn-global-common.txt](./apns/apn-global-common.txt) | List of generic and default APNs used globally. | Mobile data routing discovery |
| Access Point Names | [apns/apn-operators.txt](./apns/apn-operators.txt) | Operator-specific APN domain naming conventions. | Mobile carrier APN mapping |
| Access Point Names | [apns/apn-iot-m2m.txt](./apns/apn-iot-m2m.txt) | APNs dedicated to cellular IoT and industrial M2M devices. | Cellular IoT infrastructure auditing |
| Default Credentials | [credentials/core-network.txt](./credentials/core-network.txt) | Default credentials for 5G/4G core elements and network functions. | Core network access control checks |
| Default Credentials | [credentials/ran-elements.txt](./credentials/ran-elements.txt) | Base station and RAN controller default login combinations. | Radio Access Network auditing |
| Default Credentials | [credentials/voip-sip.txt](./credentials/voip-sip.txt) | Administrative logins for SIP Proxies, gateways, and PBXs. | VoIP infrastructure auditing |
| Default Credentials | [credentials/telco-hardware.csv](./credentials/telco-hardware.csv) | Structured default credentials database for vendor hardware. | Telecom hardware hardware audit |
| Default Credentials | [credentials/sim/sim-ota-test-keys.txt](./credentials/sim/sim-ota-test-keys.txt) | Default cryptokeys used in test SIM/eSIM cards and OTA servers. | SIM/eSIM OTA security testing |
| Protocol Brute-Force | [protocols/sip-extensions.txt](./protocols/sip-extensions.txt) | Common phone extension layouts for SIP scanning. | SIP extension brute-forcing |
| Protocol Brute-Force | [protocols/sip-usernames.txt](./protocols/sip-usernames.txt) | Standard SIP service and system usernames. | SIP account brute-forcing |
| Protocol Brute-Force | [protocols/sip/sip-passwords.txt](./protocols/sip/sip-passwords.txt) | Dictionary of common SIP/VoIP passwords extracted from defaults. | SIP password brute-forcing |
| Protocol Brute-Force | [protocols/sip/sip-headers.txt](./protocols/sip/sip-headers.txt) | Standard and custom SIP protocol headers. | SIP header parsing audits |
| Protocol Brute-Force | [protocols/sip/sip-methods.txt](./protocols/sip/sip-methods.txt) | Standard and custom SIP protocol request methods. | SIP method scanner audits |
| Protocol Brute-Force | [protocols/sip/sip-payloads.txt](./protocols/sip/sip-payloads.txt) | Input validation and injection payloads for SIP parsing. | SIP protocol injection audits |
| Protocol Brute-Force | [protocols/sip/sdp-attributes.txt](./protocols/sip/sdp-attributes.txt) | Session Description Protocol (SDP) attributes and fuzz inputs. | SDP body robustness checks |
| Protocol Brute-Force | [protocols/fuzz-generic.txt](./protocols/fuzz-generic.txt) | Generic fuzzing and boundary payloads (SQLi, command injection). | Generic parser boundary checks |
| Protocol Brute-Force | [protocols/ussd-shortcodes.txt](./protocols/ussd-shortcodes.txt) | Common carrier and device diagnostics shortcodes. | USSD diagnostic menu discovery |
| GTP Auditing | [protocols/gtp/gtp-ie-fuzzing.txt](./protocols/gtp/gtp-ie-fuzzing.txt) | Information Element fuzzing payloads for GTP-C packets. | PGW/GGSN parser robustness checks |
| GTP Auditing | [protocols/gtp/gtp-teid-bruteforce.txt](./protocols/gtp/gtp-teid-bruteforce.txt) | Sequential, boundary, and repeating hex values for TEIDs. | User plane hijacking audits |
| Signaling Auditing | [protocols/signaling/diameter-avps.txt](./protocols/signaling/diameter-avps.txt) | Commands, realms, and AVP lists for Diameter interface auditing. | Diameter edge/routing agent tests |
| Signaling Auditing | [protocols/signaling/diameter-avps-fuzzing.txt](./protocols/signaling/diameter-avps-fuzzing.txt) | AVP name-number mappings and boundary fuzz strings. | Diameter interface AVP fuzzing |
| Signaling Auditing | [protocols/signaling/ss7-global-titles.txt](./protocols/signaling/ss7-global-titles.txt) | Global Title formats and prefixes for routing audits. | SS7 MAP/CAP routing audits |
| Signaling Auditing | [protocols/signaling/ss7-point-codes.txt](./protocols/signaling/ss7-point-codes.txt) | Point codes in Zone-Area-Member and decimal formats. | SS7 network routing emulation |
| SMS Auditing | [protocols/sms/smpp-system-ids.txt](./protocols/sms/smpp-system-ids.txt) | Default system logins and system types for SMPP connections. | SMS gateway access control audits |
| SMS Auditing | [protocols/sms/sms-pdu-payloads.txt](./protocols/sms/sms-pdu-payloads.txt) | PDU payloads including Silent SMS, Flash SMS, and WAP Push. | SMS PDU processing checks |
| Roaming Identifiers | [plmns/mcc-mnc-list.txt](./plmns/mcc-mnc-list.txt) | Mobile Country Code and Network Code combinations. | PLMN ID validation and simulation |
| Roaming Identifiers | [plmns/imsi-prefixes.txt](./plmns/imsi-prefixes.txt) | Top operator IMSI prefixes for subscriber routing audits. | HSS lookup routing validation |
| 5G Core Auditing | [protocols/5g/sba-api-endpoints.txt](./protocols/5g/sba-api-endpoints.txt) | 5G Service-Based Architecture REST API paths. | Core NF endpoint discovery |
| 5G Core Auditing | [protocols/5g/network-slices.txt](./protocols/5g/network-slices.txt) | S-NSSAI identifiers (Slice Service Type and Slice Differentiator). | Slice boundary isolation audits |
| 5G Core Auditing | [protocols/5g/suci-routing-indicators.txt](./protocols/5g/suci-routing-indicators.txt) | Home Network Routing Indicator (HNRI) parameter combinations. | Subscriber routing and SEPP validation |
| 5G Core Auditing | [protocols/5g/nas-message-types.txt](./protocols/5g/nas-message-types.txt) | Hex codes for 5G Non-Access Stratum Mobility & Session Management. | Unauthenticated signaling checks |

---

## Utility Scripts

### 1. APN Permutator
Generate permutations of APN naming patterns for a given operator or country.

**Usage:**
```bash
python scripts/apn_permutator.py --operator telekom --mcc 262 --mnc 01 --output custom_apns.txt
```

### 2. IMSI Generator
Generate sequential or randomized IMSIs given an MCC, MNC, and MSIN range for testing routing or database configurations.

**Usage:**
```bash
python scripts/imsi_generator.py --mcc 262 --mnc 01 --start 000000001 --count 100 --output test_imsis.txt
```

---

## TelcoSec Projects

| Project / Platform | URL | Description |
| :--- | :--- | :--- |
| Main Website | [telcosec.net](https://www.telcosec.net/) | News, official research, and main company resources. |
| Blog | [blog.telcosec.net](https://blog.telcosec.net/) | In-depth mobile network vulnerability research and articles. |
| Academy | [app.telcosec.net](https://app.telcosec.net/) | Structured training courses and lab environments for signaling and 5G. |
| Community Hub | [community.telcosec.net](https://community.telcosec.net/) | Central access point for all community platforms and discussion channels. |
| Calculators | [calculators.telcosec.net](https://calculators.telcosec.net/) | Interactive tools for parsing and calculating cellular protocol structures. |
| Tools | [tools.telcosec.net](https://tools.telcosec.net/) | Protocol security analysis and network inspection tools. |
| CTF Portal | [ctf.telcosec.net](https://ctf.telcosec.net/) | Capture The Flag platform hosting mobile security challenges. |
| 3GPP Tracker | [3gpp.telcosec.net](https://3gpp.telcosec.net/) | Real-time monitoring of 3GPP standards, releases, and specifications. |
| Library | [library.telcosec.net](https://library.telcosec.net/) | A curated repository of whitepapers, standards, and research documents. |
| Portable BTS | [portable-bts.telcosec.net](https://portable-bts.telcosec.net/) | Lab installation guides and resources for portable base stations. |

---

## Security Guidelines and Disclaimer
Ensure all assessments are conducted with explicit, written authorization from the target network operator. Improper use of these files (e.g., transmitting invalid GTP packets or executing unauthorized SS7 signaling) can cause service disruptions on live networks.