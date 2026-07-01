# PROJECT.md - TelcoSec Platform Brief

> **Internal document - for writers, lore designers, and the marketing team.**
> All facts are sourced directly from the codebase. Do **not** publish flag answer tokens, SHA-256
> flag hashes, or lab cryptographic keys (K / OPc / WireGuard private keys) - these are challenge
> spoilers. Flag _formats_ (bracketed placeholders) are included as vocabulary reference only.

---

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [Brand & Voice](#2-brand--voice)
3. [Product Tiers - Access Model](#3-product-tiers--access-model)
4. [Content Catalog](#4-content-catalog)
5. [Gamification System](#5-gamification-system)
6. [Factions - The Faction War](#6-factions--the-faction-war)
7. [Missions & Operations](#7-missions--operations)
8. [ProLabs - Cyber Ranges](#8-prolabs--cyber-ranges)
9. [Operator Identity](#9-operator-identity)
10. [Appendix - Vocabulary & Style Guide](#10-appendix--vocabulary--style-guide)

---

## 1. Executive Summary

TelcoSec is a specialized telecom security learning and research platform built by a single founder -
**Rúben F. Silva ("RFS")**, Telecom Security Architect with 20+ years across critical infrastructure
and signaling networks (ex-Nokia, ex-Vodafone; credentials CRTP, eCPPT, eJPT). The platform operates
across two URLs:

- **`app.telcosec.net`** - the training and research application (this codebase)
- **`telco-sec.com`** - the enterprise consultancy and services arm

### The Dual-Pillar Model

The platform is built around two distinct but complementary disciplines:

| Pillar                                 | Code label              | What it delivers                                                                                                    |
| -------------------------------------- | ----------------------- | ------------------------------------------------------------------------------------------------------------------- |
| **Academy**                            | PROFESSIONAL CURRICULUM | Structured career paths from telecom fundamentals to advanced 5G/SS7 security. XP, streaks, badges, certifications. |
| **Intelligence Hub / Research Center** | PROTOCOL RESEARCH LABS  | Live SS7/Diameter/GTP protocol dissectors, signal topology visualizers, SDR tools, interactive audit logs.          |

**Mission statement (verbatim from the homepage):**

> "Two distinct pillars built for a single purpose - closing the telecom security knowledge gap for
> engineers, auditors, and analysts operating in live network environments."

**Founder's future direction:** "Architecting Secure Connectivity for 6G & Beyond" - agentic AI for
automated auditing of next-gen mobile networks.

The platform is entirely bootstrapped - built and maintained by one engineer. Community contributors
can express interest at `/contribute`.

---

## 2. Brand & Voice

### Identity

- **Primary brand name:** TelcoSec
- **Platform title:** TelcoSec Academy / TelcoSec Research Center (dual pillar)
- **Accent color:** Cyan `#00f2ff` (primary), Red `#ff0055` (danger / Offensive faction)
- **Typography:** Space Mono / monospace system font (tactical HUD aesthetic)
- **Design system:** V4 Glassmorphism - glass panels, tactical HUDs, bracket corner decorations, scanline animations

### Tone & Vocabulary

The brand speaks in a military/cyberpunk tactical register with precision technical vocabulary. Key
recurring terms:

| Term / Phrase              | Context / Usage                                          |
| -------------------------- | -------------------------------------------------------- |
| "Protocol warfare"         | General platform positioning                             |
| "Signaling attack surface" | Core subject matter                                      |
| "Dissector"                | Protocol analysis tools                                  |
| "Operative"                | Active subscriber / tier-2 plan name                     |
| "Operator"                 | Individual learner identity (player handle)              |
| "Intelligence Hub"         | Research/tools pillar                                    |
| "Designation"              | Earned certification/credential                          |
| "Barrier"                  | Proctored exam that gates a designation                  |
| "Clearance"                | Path-level completion                                    |
| HUD/OS versioning          | UI framing: `TS-HUD-OS v5.0`, `DECODER_OS::v5.4.1`       |
| "FACTION WAR"              | Competitive XP arms race between Defenders and Offensive |
| "Prolab network"           | The private cyber-range environment                      |
| "Node"                     | Server / infrastructure element in labs and operations   |

### Hero Taglines (verbatim)

- **Main hero:** "DECODING THE SIGNALING ATTACK SURFACE."
- **Sub-copy:** "Master 5G SBA, RAN, SS7, and Diameter vulnerability auditing. Access virtual signal
  intelligence labs, SDR tools, and earn industry-standard certifications."
- **Platform capability headline:** "TOOLS BUILT FOR PROTOCOL WARFARE."
- **Dual-pillar headline:** "STRUCTURED TRAINING. LIVE RESEARCH."
- **Final CTA:** "YOUR ACCESS STARTS NOW."

### SEO / Meta Identity

- Page title: `TelcoSec | 5G & Telecom Security Learning Platform`
- OG title: `TelcoSec | Expert Telecom Security Hub`
- Description: "Specialized learning paths, SDR labs, and protocol analysis tools for telecom security
  professionals. Master 5G Core, RAN, SS7/Diameter, and signaling protocol security."
- SR-only H1: `TelcoSec | Advanced 5G, RAN & Signaling Security Learning Platform`

### Standards Alignment (regulatory strip)

| Standard    | Description                              |
| ----------- | ---------------------------------------- |
| 3GPP SBA    | Release 18 & 19 Specification compliance |
| GSMA NESAS  | SCAS aligned security audits             |
| ETSI SEC    | European IoT protocol standards          |
| MITRE FiGHT | Mobile network threat cataloging         |

### Platform Stats (homepage advertised)

- `{TOTAL_CURRICULUM_MODULES}+` Curriculum Modules (computed dynamically)
- `140+` Hours of Labs
- `4` Industry Standards
- `3` Certification Paths (homepage-curated, not the full 6-cert lineup)

### Enterprise Bridge

The platform connects to enterprise services at `telco-sec.com` via the "CARRIER-GRADE SECURITY
SERVICES" section:

| Service             | Destination                              |
| ------------------- | ---------------------------------------- |
| SIGNALING AUDITS    | `https://ss7-attacks.telco-sec.com`      |
| TACTICAL HARDWARE   | `https://www.telco-sec.com/portable-bts` |
| EXECUTIVE BRIEFINGS | `https://www.telco-sec.com/contact`      |

Certified talent from the platform routes to: `https://telco-sec.com/funnels/certified-talent?ref=cert_<pathCode>`.

---

## 3. Product Tiers - Access Model

### Plans

| Tier ID | Plan Name     | Plan Code       | Type label    | Price (EUR)         | Sections unlocked                                                                    |
| ------- | ------------- | --------------- | ------------- | ------------------- | ------------------------------------------------------------------------------------ |
| `free`  | **Pilot**     | `PILOT_ACCESS`  | PROVISIONAL   | €0 / forever        | `/learn`, `/defense`                                                                 |
| `tier1` | **Scout**     | `SCOUT_LEVEL`   | RECOGNIZED    | €19.99/mo · €199/yr | + `/prolabs`, `/research`, `/intelligence`, `/attack-vectors`, `/client`, `/devices` |
| `tier2` | **Operative** | `OPERATIVE`     | ACTIVE_NODE   | €199/mo · €1,990/yr | + `/osint`, `/operations`, `/ran`, `/wireless`                                       |
| `tier3` | **Admiral**   | `ADMIRAL_SUITE` | INSTITUTIONAL | Custom / ARR        | + `/signaling`                                                                       |

Annual plans save ~17% vs monthly. Tier aliases used internally: `tier1` = `researcher`, `tier2` =
`professional`, `tier3` = `enterprise`.

### Plan Feature Summary

**Pilot (free)**
Full Academy Library (5G, GSM, LTE, IMS), Structured Protocol Study Labs, XP & Progress Tracking,
Learning Path Explorer, Certification Roadmaps, Community Intel Feed.

**Scout (tier1 / researcher)**
Everything in Pilot + Research Protocols Library, Threat Intelligence Database, Attack Vector Analysis
Modules, ProLabs Environment Access, Intelligence Reports (RSS Feed), Researcher Identity Badge.

**Operative (tier2 / professional)**
Everything in Scout + OSINT Toolkit & Recon Modules, Operations Command Center, RAN / Wireless
Deep-Dive, SDR Lab Environment, Advanced Leaderboard & Achievements, Priority Technical Liaison,
Early Access to New Content.

**Admiral (tier3 / enterprise)**
Everything in Operative + Core Network & Signaling Lab, 20+ Dedicated Research Nodes, SAML/SSO
Integration, Institutional Learning Paths, Compliance Audit Tooling (NIS2), Dedicated Account
Manager, SLA & Support Guarantee.

### Add-ons ("Node_Expansions")

| Add-on key   | Label       | Notes                                                                 |
| ------------ | ----------- | --------------------------------------------------------------------- |
| `addon_sdr`  | SDR Node    | SDR hardware bridge via ZMQ for USRP B200/BladeRF/HackRF (Operative+) |
| `addon_logs` | Signal Logs | Extended audit log retention                                          |
| `addon_ai`   | AI Credits  | Cloudflare Workers AI usage credits                                   |

Addon `addon_streak_freeze` is a special consumable item that preserves a streak if activated before
the 48-hour grace window closes.

### Trial / Reverse Trial

Active users get a 48-hour reverse trial granting **tier2** access, resolved in `getEffectiveTier()`
server-side. `role === 'team'` or `role === 'tester'` always resolves to tier3 with no subscription.

---

## 4. Content Catalog

### 4.1 Courses (10 published)

| Course                             | Code      | Difficulty   | Total Points | Designation Earned                          |
| ---------------------------------- | --------- | ------------ | ------------ | ------------------------------------------- |
| Telecom Fundamentals               | TELCO-101 | Beginner     | 3 470        | `TSSA_FOUNDATIONS` (TELCO_FOUNDATION badge) |
| PSTN Fundamentals                  | PSTN-101  | Beginner     | 1 600        | `TSS_PSF` (PSTN_FOUNDATIONS badge)          |
| GSM Fundamentals                   | GSM-201   | Intermediate | 1 600        | -                                           |
| Signaling Security Mastery         | SS7-401   | Advanced     | 3 540        | `TSS_SS7` (via barrier module)              |
| 5G Fundamentals                    | 5GF-101   | Beginner     | 2 210        | -                                           |
| 5G NR Fundamentals                 | 5GNR-101  | Intermediate | 1 250        | -                                           |
| 5G Security Specialist             | 5GS-401   | Expert       | 3 700        | `TSS_5G` (via hardening check)              |
| IMS & SIP Masterclass              | IMS-201   | Intermediate | 1 700        | `TSS_IMS` (via knowledge check)             |
| LTE & EPC Security Fundamentals    | TELCO-LTE | Intermediate | 1 600        | -                                           |
| VoIP and IMS Security Fundamentals | VOIP-201  | Intermediate | 1 600        | `TSS_IMS` (via knowledge check)             |

**Content scale per course:** ~222 total lesson `.md` files across all courses. Approximate breakdown:
~160 reading lessons · ~100 quizzes · ~14 final exams/barrier assessments · several inline labs.

### 4.2 Career Tracks (6)

| Track key          | Label                      | Color     | Icon |
| ------------------ | -------------------------- | --------- | ---- |
| SIGNALING_SECURITY | Signaling Security Analyst | `#f43f5e` | ◈    |
| 5G_SECURITY        | 5G Security Engineer       | `#8b5cf6` | ◉    |
| MOBILE_RESEARCH    | Mobile Security Researcher | `#f59e0b` | ◎    |
| NETWORK_DEFENSE    | Network Defense Engineer   | `#0ea5e9` | ⬡    |
| CRITICAL_INFRA     | Critical Infra Analyst     | `#94a3b8` | ◆    |
| LAWFUL_INTEL       | Lawful Intel Specialist    | `#dc2626` | ◈◈   |

### 4.3 Career Paths (17 defined - 11 live, 6 Coming Soon)

Order reflects `ACADEMY_PATH_ORDER` groupings:

**Tier 1 - Foundation**

| Path slug                  | Title                    | Code | Badge            | Career Track       |
| -------------------------- | ------------------------ | ---- | ---------------- | ------------------ |
| `telecom-foundations-path` | Telecom Foundations Path | BASE | TELCO_FOUNDATION | (entry - no track) |

**Tier 2 - Signaling & Protocol Security**

| Path slug                | Title                           | Code    | Badge                   | Career Track       |
| ------------------------ | ------------------------------- | ------- | ----------------------- | ------------------ |
| `signaling-analyst-path` | Signaling Security Analyst      | SIG-ANA | SIGNALING_ANALYST       | SIGNALING_SECURITY |
| `signaling-path`         | Signaling Security Mastery      | SIG     | SIGNALING_MASTER        | SIGNALING_SECURITY |
| `gsm-fundamentals-path`  | GSM & Legacy Network Security   | GSM     | GSM_SECURITY_SPECIALIST | SIGNALING_SECURITY |
| `pstn-fundamentals-path` | PSTN & Fixed Network Security   | PSTN    | PSTN_FOUNDATIONS        | (no track)         |
| `ims-path`               | IMS & VoIP Security Masterclass | IMS     | IMS_SIP_MASTER          | SIGNALING_SECURITY |

**Tier 3 - 5G & New Radio**

| Path slug                 | Title                  | Code   | Badge                  | Career Track |
| ------------------------- | ---------------------- | ------ | ---------------------- | ------------ |
| `5g-engineer-path`        | 5G Security Engineer   | 5G-ENG | 5G_SECURITY_ENGINEER   | 5G_SECURITY  |
| `5g-security-path`        | 5G Security Specialist | 5G     | 5G_SECURITY_SPECIALIST | 5G_SECURITY  |
| `5g-fundamentals-path`    | 5G Fundamentals        | 5GF    | 5G_FOUNDATIONS         | (no track)   |
| `5g-nr-fundamentals-path` | 5G NR Fundamentals     | 5GNR   | 5G_NR_SPECIALIST       | (no track)   |

**Tier 4 - LTE & Mobile**

| Path slug           | Title              | Code | Badge                  | Career Track |
| ------------------- | ------------------ | ---- | ---------------------- | ------------ |
| `lte-security-path` | LTE & EPC Security | LTE  | EPC_SECURITY_ARCHITECT | 5G_SECURITY  |

**Coming Soon - Research & Specialized Tracks**

| Path slug                     | Title                                    | Code     | Badge                        | Career Track    |
| ----------------------------- | ---------------------------------------- | -------- | ---------------------------- | --------------- |
| `mobile-equipments-path`      | Mobile Equipment Security                | MEQS     | MOBILE_HARDWARE_ANALYST      | MOBILE_RESEARCH |
| `baseband-path`               | Baseband Security Research               | BASEBAND | BASEBAND_RESEARCH_OPERATOR   | MOBILE_RESEARCH |
| `railway-security-path`       | Railway Network Security                 | RAIL     | RAILWAY_SECURITY_GUARD       | CRITICAL_INFRA  |
| `specialized-ntn-path`        | Satellite & NTN Networks                 | SPEC     | SATELLITE_FRONTIER_OPERATIVE | NETWORK_DEFENSE |
| `transmission-transport-path` | Transmission & Transport Security        | TRAN     | GLOBAL_BACKBONE_ARCHITECT    | NETWORK_DEFENSE |
| `telco-operations-path`       | Telecom Operations & Lawful Intelligence | OPS      | OPS_SPECIALIST               | LAWFUL_INTEL    |

### 4.4 Certifications (6 designations)

Certifications (called "designations") are cryptographically signed and publicly verifiable.
Issued by: `"TelcoSec Authority Engine"` / authority: `"Global Telecom Security Research Hub"` /
integrity: `"SHA-256 Sealed"`.

| Code    | Full Title                                           | Tier req | Prereq  | Hours | Difficulty   | Career Relevance                                                                      |
| ------- | ---------------------------------------------------- | -------- | ------- | ----- | ------------ | ------------------------------------------------------------------------------------- |
| TSSA-F  | TelcoSec Security Associate - Foundations            | free     | none    | -     | Beginner     | Telecom Security Analyst, Core Network Auditor, Fraud Investigator                    |
| TSS-PSF | PSTN Security Foundations                            | free     | none    | 8h    | Beginner     | Telecom Security Analyst, Core Network Auditor, Fraud Investigator                    |
| TSS-GSM | Telecom Signaling Specialist - GSM & Legacy Networks | tier1    | TSSA-F  | 14h   | Intermediate | Signaling Security Specialist, Legacy Systems Auditor, Telecom Threat Hunter          |
| TSS-IMS | Telecom Signaling Specialist - IMS & VoIP            | tier1    | TSSA-F  | 28h   | Intermediate | IMS Core Security Engineer, VoIP Security Analyst, VoIP Fraud Specialist              |
| TSS-SS7 | Telecom Signaling Specialist - SS7 & Diameter        | tier3    | TSS-GSM | 42h   | Advanced     | Interconnect Security Architect, Core Network Engineer, Signaling Firewall Specialist |
| TSS-5G  | Telecom Security Specialist - 5G Core                | tier2    | TSSA-F  | 3h    | Expert       | 5G Security Engineer, NF Security Analyst, O-RAN Threat Researcher                    |

**Prerequisite chain:** TSSA-F → TSS-GSM → TSS-SS7 (the signaling mastery track);
TSSA-F → TSS-IMS / TSS-5G (parallel specialist tracks).

**Verification mechanic:** Each issued cert receives a public `verifyHash` (first 16 chars of
`SHA-256(certId:certSalt)`) accessible at `/verify/[hash]`. The LinkedIn "Add to Profile" URL
routes to org ID `107901390`. The consultancy talent funnel URL is
`https://telco-sec.com/funnels/certified-talent?ref=cert_<pathCode>&v=<verifyHash>`.

---

## 5. Gamification System

The gamification engine is authoritative server-side. Client components reflect state but never
grant rewards. The engine is called "the authoritative state engine for academy gamification."

### 5.1 XP - Experience Points

**Module XP by difficulty** (source: `server/utils/stats-helper.ts` → `XP_MAP`):

| Difficulty   | XP                 |
| ------------ | ------------------ |
| Intro        | 100                |
| Beginner     | 150                |
| Easy         | 250                |
| Medium       | 500                |
| Intermediate | 750                |
| Specialist   | 750                |
| Advanced     | 750                |
| Hard         | 1 000              |
| Professional | 1 000              |
| Expert       | 1 500              |
| Insane       | 2 000              |
| Ref / ALL    | 0 (utility, no XP) |

Default fallback when difficulty is unmatched: **300 XP**.

**Non-module XP sources:**

| Source                    | XP per unit       |
| ------------------------- | ----------------- |
| Signaling audit log entry | 25 XP             |
| Badge held                | 75 XP             |
| Achievement reward        | varies (see §5.3) |

**Streak XP multiplier** (applied to base module XP on completion):

| Active streak | Multiplier |
| ------------- | ---------- |
| ≥ 30 days     | ×1.5       |
| ≥ 7 days      | ×1.25      |
| ≥ 3 days      | ×1.1       |
| < 3 days      | ×1.0       |

Result = `Math.round(baseXP × multiplier)`.

### 5.2 Rank Ladder (9 levels)

Source: `app/constants/ranks.ts`. The rank ladder is the primary identity progression for the
lore writer - every operator begins as a Recruit and can rise to Legend.

| Level | Rank Name            | XP Threshold     |
| ----- | -------------------- | ---------------- |
| 1     | **RECRUIT**          | 0 – 500          |
| 2     | **ANALYST**          | 500 – 1 500      |
| 3     | **SPECIALIST**       | 1 500 – 4 000    |
| 4     | **EXPERT**           | 4 000 – 10 000   |
| 5     | **ARCHITECT**        | 10 000 – 20 000  |
| 6     | **SENIOR_ARCHITECT** | 20 000 – 35 000  |
| 7     | **ELITE_OPERATOR**   | 35 000 – 60 000  |
| 8     | **MASTER**           | 60 000 – 100 000 |
| 9     | **LEGEND**           | 100 000+         |

At LEGEND, the progress bar uses a rolling 50 000 XP band above the 100k threshold.

### 5.3 Achievements (full catalog)

Source: `app/data/achievements.ts` / `server/utils/achievements.ts`.
Format: **ID** - "Title" - "Description" - XP reward.

#### Module Progress

| ID           | Title              | Description                | XP Reward |
| ------------ | ------------------ | -------------------------- | --------- |
| FIRST_MODULE | First Contact      | Complete your first module | 100       |
| MODULES_5    | Entry Analyst      | Complete 5 modules         | 250       |
| MODULES_10   | Operational        | Complete 10 modules        | 500       |
| MODULES_25   | Senior Analyst     | Complete 25 modules        | 1 000     |
| MODULES_50   | Protocol Master    | Complete 50 modules        | 2 500     |
| MODULES_75   | Network Specialist | Complete 75 modules        | 4 000     |
| MODULES_100  | Telecom Architect  | Complete 100 modules       | 7 500     |

#### Streak Records

| ID         | Title               | Description               | XP Reward |
| ---------- | ------------------- | ------------------------- | --------- |
| STREAK_3   | Three-Day Signal    | Maintain a 3-day streak   | 150       |
| STREAK_7   | Week Warrior        | Maintain a 7-day streak   | 500       |
| STREAK_14  | Fortnight Operative | Maintain a 14-day streak  | 1 000     |
| STREAK_30  | Monthly Operative   | Maintain a 30-day streak  | 2 000     |
| STREAK_60  | Two-Month Operative | Maintain a 60-day streak  | 5 000     |
| STREAK_100 | Centurion Operator  | Maintain a 100-day streak | 10 000    |

#### XP Milestones

| ID       | Title            | Description    | XP Reward |
| -------- | ---------------- | -------------- | --------- |
| XP_500   | Field Analyst    | Earn 500 XP    | 100       |
| XP_1500  | Specialist       | Earn 1,500 XP  | 200       |
| XP_4000  | Expert Operator  | Earn 4,000 XP  | 350       |
| XP_10000 | Architect        | Earn 10,000 XP | 500       |
| XP_20000 | Senior Architect | Earn 20,000 XP | 750       |
| XP_35000 | Elite Operator   | Earn 35,000 XP | 1 200     |
| XP_60000 | Legend           | Earn 60,000 XP | 2 000     |

#### Course Completions (barrier / final assessment)

| ID                       | Title                     | Trigger module ID             | XP Reward |
| ------------------------ | ------------------------- | ----------------------------- | --------- |
| COURSE_TELECOM_COMPLETE  | TSSA Foundations          | `telecom-foundations-barrier` | 500       |
| COURSE_SS7_COMPLETE      | TSS SS7                   | `ss7-barrier-module`          | 750       |
| COURSE_DIAMETER_COMPLETE | TSS Diameter              | `diameter-knowledge-check`    | 750       |
| COURSE_GSM_COMPLETE      | GSM/2G Analyst            | `gsm-knowledge-check`         | 600       |
| COURSE_IMS_COMPLETE      | IMS Core Operator         | `ims-knowledge-check`         | 600       |
| COURSE_VOIP_COMPLETE     | VoIP Security Auditor     | `voip-knowledge-check`        | 600       |
| COURSE_LTE_EPC_COMPLETE  | LTE/EPC Security Engineer | `lte-epc-knowledge-check`     | 750       |
| COURSE_5GF_COMPLETE      | 5G Fundamentals           | `5gf-knowledge-check`         | 750       |
| COURSE_5GNR_COMPLETE     | 5G NR Specialist          | `5gnr-knowledge-check`        | 750       |
| COURSE_PSTN_COMPLETE     | PSTN Heritage Engineer    | `pstn-knowledge-check`        | 600       |
| COURSE_5GS_COMPLETE      | 5G Security Specialist    | `5gs-final-exam`              | 800       |

#### ProLab Completions

| ID                  | Title                     | Trigger module ID           | XP Reward |
| ------------------- | ------------------------- | --------------------------- | --------- |
| 5G_SA_OPERATOR      | 5G SA Security Operator   | `prolabs-5g-sa-core`        | 400       |
| LTE_ENB_OPERATOR    | LTE eNB Security Operator | `prolabs-lte-enb-security`  | 350       |
| BASEBAND_RESEARCHER | Baseband Researcher       | `prolabs-baseband-research` | 300       |

#### Lab Count Milestones

| ID        | Title              | Description                             | XP Reward |
| --------- | ------------------ | --------------------------------------- | --------- |
| FIRST_LAB | Lab Access Granted | Complete your first hands-on lab        | 200       |
| LABS_5    | Field Technician   | Complete 5 practical labs or exercises  | 500       |
| LABS_15   | Hands-On Expert    | Complete 15 practical labs or exercises | 1 500     |

#### Capstone Completions

| ID               | Title                    | Trigger module ID  | XP Reward |
| ---------------- | ------------------------ | ------------------ | --------- |
| CAPSTONE_TELECOM | Foundations Capstone     | `capstone-project` | 300       |
| CAPSTONE_GSM     | GSM Field Operations     | `gsm-capstone`     | 350       |
| CAPSTONE_LTE     | LTE Field Operations     | `lte-capstone`     | 350       |
| CAPSTONE_VOIP    | VoIP Tactical Deployment | `voip-capstone`    | 350       |
| CAPSTONE_PSTN    | PSTN Heritage Operations | `pstn-capstone`    | 300       |

#### Path Mastery (awarded when all path modules are completed)

Achievement IDs are generated as `PATH_<CODE>_COMPLETE`:

| ID                     | Title                        | XP Reward |
| ---------------------- | ---------------------------- | --------- |
| PATH_BASE_COMPLETE     | Foundations Clearance        | 1 000     |
| PATH_SIG_COMPLETE      | Signaling Authority          | 1 500     |
| PATH_SIG-ANA_COMPLETE  | Signaling Analyst Certified  | 2 000     |
| PATH_5G_COMPLETE       | 5G Integrity Specialist      | 2 000     |
| PATH_5G-ENG_COMPLETE   | 5G Security Engineer         | 2 000     |
| PATH_5GF_COMPLETE      | 5G Foundations Cleared       | 750       |
| PATH_5GNR_COMPLETE     | 5G NR Air Interface          | 1 000     |
| PATH_IMS_COMPLETE      | Voice Backbone Tech          | 1 000     |
| PATH_GSM_COMPLETE      | GSM Heritage Analyst         | 1 000     |
| PATH_PSTN_COMPLETE     | PSTN Heritage Analyst        | 750       |
| PATH_LTE_COMPLETE      | EPC Security Architect       | 1 500     |
| PATH_RAIL_COMPLETE     | Railway Network Guard        | 1 000     |
| PATH_SPEC_COMPLETE     | Satellite Frontier Operative | 1 500     |
| PATH_TRAN_COMPLETE     | Global Backbone Architect    | 1 500     |
| PATH_MEQS_COMPLETE     | Mobile Hardware Analyst      | 1 000     |
| PATH_BASEBAND_COMPLETE | Baseband Research Operator   | 2 000     |
| PATH_OPS_COMPLETE      | LI Operations Certified      | 2 000     |

### 5.4 Badges & Designations

Source: `app/data/badges.ts` (`BADGE_METADATA`) + `app/constants/curriculum.ts`
(`ACADEMY_DESIGNATIONS`).

#### Path Completion Badges

| Badge ID                     | Label                        | Glyph | Color     |
| ---------------------------- | ---------------------------- | ----- | --------- |
| TELCO_FOUNDATION             | Telecom Foundations          | ⬡     | `#34d399` |
| SIGNALING_ANALYST            | Signaling Analyst            | ◈     | `#f43f5e` |
| SIGNALING_MASTER             | Signaling Mastery            | ◈     | `#f43f5e` |
| 5G_SECURITY_SPECIALIST       | 5G Security Specialist       | ◉     | `#8b5cf6` |
| 5G_SECURITY_ENGINEER         | 5G Security Engineer         | ◉     | `#8b5cf6` |
| 5G_FOUNDATIONS               | 5G Foundations               | ◉     | `#0ea5e9` |
| 5G_NR_SPECIALIST             | 5G NR Air Interface          | ◉     | `#0ea5e9` |
| IMS_SIP_MASTER               | IMS & SIP Mastery            | ⬟     | `#f472b6` |
| PSTN_FOUNDATIONS             | PSTN Foundations             | ⬡     | `#34d399` |
| GSM_SECURITY_SPECIALIST      | GSM Security Specialist      | ⬟     | `#ea580c` |
| RAILWAY_SECURITY_GUARD       | Railway Network Guard        | ◆     | `#94a3b8` |
| SATELLITE_FRONTIER_OPERATIVE | Satellite Frontier Operative | ◉     | `#a855f7` |
| GLOBAL_BACKBONE_ARCHITECT    | Global Backbone Architect    | ⬡     | `#0ea5e9` |
| EPC_SECURITY_ARCHITECT       | EPC Security Architect       | ◉     | `#3b82f6` |
| MOBILE_HARDWARE_ANALYST      | Mobile Hardware Analyst      | ⬟     | `#6366f1` |
| BASEBAND_RESEARCH_OPERATOR   | Baseband Research Operator   | ◈     | `#f59e0b` |
| OPS_SPECIALIST               | LI Operations Specialist     | ◈     | `#dc2626` |

#### Designation Badges (ACADEMY_DESIGNATIONS - awarded on barrier module completion)

| Trigger module ID             | Designation Code | Full Name                                            | Color     |
| ----------------------------- | ---------------- | ---------------------------------------------------- | --------- |
| `telecom-foundations-barrier` | TSSA_FOUNDATIONS | TelcoSec Security Associate - Foundations            | `#34d399` |
| `pstn-knowledge-check`        | TSS_PSF          | PSTN Security Foundations                            | `#00f2ff` |
| `gsm-knowledge-check`         | TSS_GSM          | Telecom Signaling Specialist - GSM & Legacy Networks | `#ea580c` |
| `ss7-barrier-module`          | TSS_SS7          | Telecom Signaling Specialist - SS7 & Diameter        | `#f43f5e` |
| `5g-hardening-checks`         | TSS_5G           | Telecom Security Specialist - 5G Core                | `#8b5cf6` |
| `ims-knowledge-check`         | TSS_IMS          | Telecom Signaling Specialist - IMS & VoIP            | `#f472b6` |

#### Operations & ProLab Mission Badges

| Badge ID              | Awarded by                           |
| --------------------- | ------------------------------------ |
| `prolab-operator`     | Mission 00 - ProLab VPN access setup |
| `5g-sa-operator`      | 5G SA Core ProLab (all challenges)   |
| `lte-enb-operator`    | LTE eNB Security ProLab              |
| `baseband-researcher` | Baseband Emulator ProLab             |
| `iot-sim-analyst`     | IoT SIM Security ProLab              |
| `ss7-analyst`         | SS7 SRI-for-SM case study            |
| `diameter-analyst`    | Diameter S6a ULR case study          |
| `gtp-analyst`         | GTP-C Tunnel Hijack case study       |

### 5.5 Streaks

Source: `server/utils/stats-helper.ts`, `app/components/DashboardStreakPanel.vue`.

- **Grace window:** 48 hours from last completion.
- **Same UTC day:** no change to streak count.
- **New day within 48h:** streak increments +1.
- **Beyond 48h:** streak resets to 1 (lost).
- **Streak Freeze:** addon `addon_streak_freeze` (status `active`) - if activated before grace expires,
  the streak is preserved and consumed (status → `used`). One-time use per item.
- **`streakAtRisk` flag:** fires when `currentStreak > 0` and operator has been inactive > 24 hours.
  UI shows: `"STREAK AT RISK · {N}H LEFT"` in amber (`#ffa000`).
- **Dashboard copy:** "Activity Streak", 14-day heatmap, "BEST {N}D", count-up animation on increment.
- **Streak ≥ 7:** display color switches to green (tactical success signal).

---

## 6. Factions - The Faction War

Source: profile components, `app/pages/leaderboard.vue`, `server/api/leaderboard/xp.get.ts`,
`server/database/schema.ts` (`users.fraction`).

### The Two Factions

> **"FACTION WAR - GLOBAL XP ARMS RACE"**

| Faction       | Color                 | Icon               | Enrollment display     |
| ------------- | --------------------- | ------------------ | ---------------------- |
| **DEFENDERS** | Cyan `#00f2ff`        | `lucide:shield`    | "Enrolled as DEFENDER" |
| **OFFENSIVE** | Red/Magenta `#ff0055` | `lucide:crosshair` | "OFFENSIVE OPERATOR"   |

**Faction descriptions (verbatim from profile enrollment panel):**

- **DEFENDERS:** "Protect telecom infrastructure. Focus on defense, monitoring, and incident response."
- **OFFENSIVE:** "Probe and exploit telecom vulnerabilities. Focus on research, pentesting, and attack simulation."

Operators with no faction selected are unaffiliated. Faction is set on the Profile page.
Unaffiliated prompt: "Enlist in your faction on your Profile page."

### Faction War Leaderboard

The leaderboard header reads: **"FACTION WAR - GLOBAL XP ARMS RACE"**

The leaderboard shows:

- **Aggregate XP pools** per faction - the war score.
- **Member counts** per faction.
- **XP split visualization** - percentage bar (Defenders vs Offensive).
- **Top operators** with faction badge, rank, streak, and XP.

### Leaderboard Scopes

| Scope      | Filter                    | What it shows                          |
| ---------- | ------------------------- | -------------------------------------- |
| `global`   | none                      | All operators, ranked by XP            |
| `fraction` | `defender` or `offensive` | Per-faction ranking                    |
| `country`  | country name string       | Operators from a specific country      |
| season     | `season_id` integer       | Historical snapshot from a past season |

Top 50 shown by default. Current user's position shown even if outside top 50 (`myEntry`).

**Medal colors:** 1st = Gold `#ffcc00` · 2nd = Silver `#b4b4b4` · 3rd = Bronze `#cd7f32`.

### Seasons

Historical XP snapshots stored in `seasonSnapshots` table: rank, userId, xpAtEnd, fraction, country.
Seasons represent competitive periods; past seasons accessible via `season_id` query param.

---

## 7. Missions & Operations

Source: `content/operations/missions/`, `content/operations/case-studies/`,
`server/api/operations/missions/`, `app/pages/operations/index.vue`.

### Operator Rank Track (Operations)

Operators progress through a second rank system - the Ops track - based on validated missions and
hardware achievements:

| Ops Rank            | Requirements                           |
| ------------------- | -------------------------------------- |
| **Unranked**        | No missions completed                  |
| **Signal Trainee**  | ≥1 mission completed                   |
| **Field Analyst**   | ≥3 missions completed                  |
| **RF Operator**     | ≥1 hardware-verified mission           |
| **Senior Operator** | ≥1 hardware-verified + ≥3 CVE missions |
| **Expert Operator** | ≥5 hardware-verified + ≥5 CVE missions |

Hardware verification is required for RF-tier missions. Verified hardware types include:
`simtrace2`, `hackrf`, and analogous SDR/SIM tooling.

### Four-Phase Engagement Lifecycle

Every operator on the ops track works through this methodology loop (verbatim labels from the UI):

**Phase 01 - INTELLIGENCE GATHERING**
"Enumerate operator infrastructure from public sources."
Skills: PLMN Resolution · BGP Topology Mapping · Diameter Realm Enumeration · SS7 GT Discovery

**Phase 02 - ATTACK SURFACE MAPPING**
"Correlate intelligence with known attack surfaces."
Skills: Surface Correlation · Signaling Exposure Analysis · NRF Enumeration · CVE Cross-Reference

**Phase 03 - CONTROLLED LAB VALIDATION**
"Validate identified attack paths in authorized lab environments."
Skills: SS7 MAP Probing · Diameter Testing · 5G NF Enumeration · SDR Air-Interface Capture

**Phase 04 - FINDINGS & REPORTING**
"Structure results into standards-compliant assessment reports."
Skills: FiGHT TTP Mapping · CVSS Scoring · TS 33.117 Alignment · IR.82 Reporting

### Mission 00 - ProLab VPN Access

> **Classification:** VPN Setup · Beginner · 100 pts · Badge: `prolab-operator`
> **Mission ID:** `ops-mission-00-prolab-vpn`

The first mission is an onboarding gate: the operator must establish a WireGuard tunnel to the
TelcoSec ProLab private network. This is the mandatory entry point before any cyber-range challenge.

**ProLab Network Architecture:**

| Node       | IP Address   | Technology                                     |
| ---------- | ------------ | ---------------------------------------------- |
| Gateway    | `10.10.0.1`  | WireGuard gateway + verify endpoint            |
| GSM Core   | `10.10.1.10` | OsmocomBB · ARFCN 877 · MCC 001 MNC 01         |
| LTE Core   | `10.10.1.20` | srsRAN + Open5GS EPC · EARFCN 1800             |
| 5G SA Core | `10.10.1.30` | srsRAN Project + Open5GS 5GC · NR-ARFCN 368500 |
| IMS Stack  | `10.10.1.40` | Kamailio + FHoSS                               |
| SIM Lab    | `10.10.1.50` | pySIM server · SimTrace2 APDU relay            |

Mission 00 hints walk the operator through: downloading the WireGuard config, bringing the tunnel up
with `wg-quick up telcosec-prolab.conf`, and verifying connectivity at `http://10.10.0.1/verify`.

> **⚠ Flag answers, SHA-256 hashes, and WireGuard private keys are NOT included in this document.**

### Case Study: SS7 SRI-for-SM Subscriber Geolocation

> **Classification:** OPS-ATK-001 · SS7 · CRITICAL · CVSS 9.3
> **Badge:** `ss7-analyst` · 150 pts · 45 min · Intermediate

**Attack family:** "MAP-based subscriber surveillance - the original and most-documented SS7 attack class."

**Real-world context (verbatim):**

> "This attack was publicly demonstrated live in 2017 against a German O2 subscriber and has been
> documented in operator networks globally since 2014. The attack requires no physical proximity to
> the target and can be executed from any country with SS7 interconnect access."

**Learning objectives:**

1. Understand how MAP SRI-for-SM leaks subscriber location and routing data
2. Trace the SS7 GT enumeration phase that precedes the exploit
3. Identify the network topology that enables this class of attack
4. Apply GSMA FS.11 countermeasures to eliminate or detect the attack path

### Case Study: Diameter S6a ULR - LTE Subscriber Location Disclosure

> **Classification:** OPS-ATK-004 · Diameter / S6a · HIGH · CVSS 7.5
> **Badge:** `diameter-analyst` · 150 pts · 40 min · Intermediate

**Attack family:** "Diameter interconnect abuse - the 4G/LTE equivalent of SS7 geolocation attacks."

**Core problem framing (verbatim):**

> "LTE's migration from SS7 to Diameter was marketed as a security improvement. Diameter adds TLS
> and peer authentication. However, the interconnect layer - where operator networks meet over
> IPX/GRX - still lacks end-to-end authentication enforcement in many deployments. An attacker who
> can present as a valid Diameter peer can send S6a commands directly to the HSS."

**Learning objectives:**

1. Enumerate Diameter realm infrastructure from DNS SRV records
2. Understand the S6a ULR/ULA message exchange and what subscriber data it exposes
3. Trace how an IPX-connected attacker bypasses peer validation
4. Apply GSMA FS.19 mitigations: DEA inspection, mutual TLS, HSS MME whitelisting

### Case Study: GTP-C Tunnel Hijack & IMSI Overbilling + GTPdoor 2024

> **Classification:** OPS-ATK-006 · GTP-C · HIGH · CVSS 8.6
> **Badge:** `gtp-analyst` · 200 pts · 50 min · Advanced

**Attack family:** "GTP control plane abuse over roaming GRX/IPX - user-plane tunnel hijacking and
billing fraud."

**Why GTP matters (verbatim):**

> "GPRS Tunnelling Protocol (GTP) is the data-plane protocol of every generation of mobile network
> from 2G GPRS through 4G LTE. All subscriber data sessions traverse GTP tunnels between RAN nodes
> and packet gateways. The GTP-C control plane manages tunnel lifecycle - creation, modification, and
> deletion of PDP Contexts (3G) and EPS Bearer Contexts (4G). An attacker who can send GTP-C messages
> to a live SGSN or SGW owns the data plane."

**GTPdoor (2024) context:**
In 2024, researcher haxrob documented `GTPdoor` - a backdoor using GTP-C Echo Request packets as a
covert C2 channel. GTP Echo is mandatory per 3GPP spec; it generates high volume, is rarely inspected,
and is not logged by most monitoring tools. Operator firewalls whitelist GTP-C from peers - making it
an ideal C2 vector.

Documented capabilities: reverse shell execution, subscriber data exfiltration, GTP-C interception of
Create Session Requests, IMSI harvesting. At least 3 operators in Asia-Pacific and 2 in Eastern Europe
were affected. Coverage: Eclecticiq, Kaspersky, Trend Micro.

Detection IOC: Unusual GTP Echo Request traffic where TEID ≠ 0 (spec requires TEID=0); Recovery IE
contains non-standard byte patterns.

**Learning objectives:**

1. Enumerate GTP-C endpoints on the GRX/IPX roaming plane
2. Understand Create Session Request / Response exchange and TEID allocation
3. Execute a controlled tunnel hijack in ProLab (LTE SGW at 10.10.1.20)
4. Analyse the GTPdoor backdoor: how GTP-C became a C2 channel
5. Apply GSMA FS.20 GTP firewall controls

---

## 8. ProLabs - Cyber Ranges

The ProLab environment is a private, WireGuard-gated cyber range. Operators connect via Mission 00,
then access live srsRAN / Open5GS nodes to execute security challenges. No physical RF hardware is
required for VPN-mode labs.

### Lab Catalog

| Lab ID                      | Title                                 | Operator Badge        | Track    | Difficulty | Points | Duration |
| --------------------------- | ------------------------------------- | --------------------- | -------- | ---------- | ------ | -------- |
| `prolabs-5g-sa-core`        | LAB :: 5G SA Core Security Assessment | `5g-sa-operator`      | 5G NR    | Expert     | 600    | 180 min  |
| `prolabs-lte-enb-security`  | LAB :: LTE eNB Security Assessment    | `lte-enb-operator`    | LTE/EPC  | Hard       | 425    | 150 min  |
| `prolabs-baseband-research` | LAB :: Baseband Emulator Research     | `baseband-researcher` | BASEBAND | Hard       | 300    | 160 min  |
| `prolabs-iot-sim-security`  | LAB :: IoT SIM Security Assessment    | `iot-sim-analyst`     | IOT      | Hard       | 250    | 140 min  |

### LAB :: 5G SA Core Security Assessment

**Theme:** Connect to the TelcoSec private Open5GS 5G SA core over WireGuard VPN. Run srsRAN Project
gNB and UE, capture the full 5G NR Registration sequence.

**Tools:** srsRAN Project (gNB + UE), Open5GS 5GC, Wireshark/tshark.
**Network target:** `10.10.1.30` (NR-ARFCN 368500, 3GPP test PLMN MCC 999 MNC 70).
**Requirements:** Linux (8 GB RAM, 4+ CPU), WireGuard.

**Challenge structure** (flag formats - answers not included):

| #   | Challenge Title                 | Points | Difficulty | Flag Format                               |
| --- | ------------------------------- | ------ | ---------- | ----------------------------------------- |
| 1   | SUCI Identity Protection Scheme | 50     | Easy       | `FLAG{SUCI_ECIES_[PROFILE]_KEY_ID_[ID]}`  |
| 2   | Null Cipher Exposure            | 75     | Medium     | UTF-8 plaintext embedded in NAS payload   |
| 3   | NGAP Surface Mapping            | 75     | Medium     | `FLAG{NGAP_ID_[AMF_NGAP_ID]_SST_[SST]}`   |
| 4   | SIDF Bypass Probe               | 100    | Hard       | `FLAG{5GMM_[CAUSE_DECIMAL]_[CAUSE_NAME]}` |
| 5   | GTP-U Data Plane TEID           | 100    | Hard       | `FLAG{GTP_UL_TEID_[8_HEX_DIGITS]}`        |

### LAB :: LTE eNB Security Assessment

**Theme:** Connect a software eNB to the TelcoSec private Open5GS EPC. Capture EPS Attach sequence
and complete security challenges across IMSI exposure, cipher negotiation, S1AP surface mapping,
EPS-AKA, and GTP-C.

**Tools:** srsRAN LTE (eNB + UE + EPC), Open5GS EPC, Wireshark.
**Network target:** `10.10.1.20` (EARFCN 1800, MCC 001 MNC 01).
**Requirements:** Linux (4 GB RAM, 2+ CPU), WireGuard.

**Challenge structure:**

| #   | Challenge Title               | Points | Difficulty |
| --- | ----------------------------- | ------ | ---------- |
| 1   | IMSI Exposure on Uu Interface | 50     | Easy       |
| 2   | Null Cipher Negotiation       | 50     | Easy       |
| 3   | S1AP MME Surface Mapping      | 75     | Medium     |
| 4   | EPS-AKA AUTN SQN Concealment  | 75     | Hard       |
| 5   | GTP-C Session TEID            | 50     | Medium     |

### LAB :: Baseband Emulator Research

**Theme:** Build and test a software baseband stack. Attach a virtual UE to a virtual eNB via ZeroMQ
(no RF emission). Perform static and dynamic firmware reverse engineering.

**Tools:** srsRAN_4G (EPC + eNB + UE), Ghidra (static RE), FirmWire (dynamic emulation/rehosting),
Wireshark. All communication via ZeroMQ virtual RF - localhost loopback only.

**Reverse engineering targets:**

- `handle_security_mode_command` - cipher/integrity negotiation
- `write_pdu_pcch` - Paging Channel (IMSI vs TMSI paging identity)
- `handle_nas_rx` / `handle_nas_msg` - NAS PDU dispatcher
- `cipher_check` / `integrity_check` - AS security validation, null-cipher bypass conditions
- `rrc_conn_setup_complete` - RRC Connection Setup Complete handler

### LAB :: IoT SIM Security Assessment

**Theme:** Explore the UICC/SIM attack surface using programmable test SIMs and PC/SC tooling. Audit
OTA/BIP toolkit, analyse known SIM attack classes.

**Hardware required:** USB PC/SC smart card reader (ACS ACR38, SCM SCR3310, or HID Omnikey) +
programmable test SIMs (sysmoUSIM-SJS1 or sysmoISIM-SJA5).
**Tools:** pySim · pcscd · osmo-sim-auth · pySIM-shell.
**Test IMSI range:** `001010000000000` - `001019999999999` (3GPP test PLMN).

**Attack classes covered:**

| Attack                       | Technical Method                                                                            |
| ---------------------------- | ------------------------------------------------------------------------------------------- |
| COMP128v1/v2 Key Cloning     | ~150K chosen auth queries to recover Ki                                                     |
| OTA SMS-PP Command Injection | Binary SMS with Transport Key (TK) for UICC control                                         |
| Simjacker / S@T Browser RCE  | OTA-formatted envelope to S@T service (bit 48 of EF.UST), LAUNCH BROWSER                    |
| BIP / CAT Toolkit Exposure   | Bearer Independent Protocol - OPEN CHANNEL, TCP/IP from card; M2M SGP.02 vs consumer SGP.22 |

---

## 9. Operator Identity

Every platform user has an **Operator profile** - the in-world identity layer for the gamification
and faction systems.

### Profile Fields

| Field             | Notes                                                                                                                       |
| ----------------- | --------------------------------------------------------------------------------------------------------------------------- |
| `operator_handle` | User-settable callsign; uppercase-sanitized; max 20 chars. Default: `UNSET_HANDLE`. Displayed on leaderboard as "OPERATOR". |
| `bio`             | Max 280 chars; styled as "Input operational objectives or background…"                                                      |
| `work_company`    | Organization / operator affiliation                                                                                         |
| `work_position`   | Role / job title                                                                                                            |
| `study_institute` | Academic institution (optional)                                                                                             |
| `study_major`     | Study field (optional)                                                                                                      |
| `city`            | Location city                                                                                                               |
| `country`         | Location country (used in country-scoped leaderboard)                                                                       |
| `fraction`        | Faction: `'defender'` · `'offensive'` · `null` (unaffiliated)                                                               |

### Profile Verification Badges

| Badge            | Condition                            |
| ---------------- | ------------------------------------ |
| Verified         | Auth0 email verified                 |
| Profile complete | `work_company` AND `city` are filled |

### WireGuard / ProLab Config

Each operator enrolled in the ProLab program receives a unique WireGuard configuration
(`prolabVpnConfigs` table):

- Unique private key (client-side only - never stored in plaintext after issuance)
- Unique client IP (`10.10.X.Y/32`)
- Server public key + endpoint (`<prolab-server>:51820`)
- AllowedIPs: `10.10.0.0/24`
- PersistentKeepalive: 25 seconds

Config is served only to the config owner. All ProLab labs use the 3GPP test PLMN
(MCC 001 / MNC 01 or MCC 999 / MNC 70) and a standard test IMSI for reproducibility.

---

## 10. Appendix - Vocabulary & Style Guide

### 10.1 Core Vocabulary Cluster

For the lore writer - platform-coined terms and their registered usage:

| Term                  | Definition / Usage                                                                                                      |
| --------------------- | ----------------------------------------------------------------------------------------------------------------------- |
| **Operator**          | The individual learner's in-world identity. Never "user" in brand copy.                                                 |
| **Operative**         | The tier-2 subscription plan name AND the general brand term for active field operators.                                |
| **Designation**       | A named credential earned by completing a learning path or barrier (e.g., TSS_SS7). Never "certificate" in the UI.      |
| **Barrier**           | A proctored assessment that must be passed at ≥80% to earn a Designation. Lore: it's a gateway, not just a test.        |
| **Clearance**         | Awarded on path completion (e.g., "Foundations Clearance"). Implies access and trust.                                   |
| **Intel**             | Any research-tier content (case studies, signals analysis, threat feeds). Used where others would say "article".        |
| **Signal**            | Both the RF physics meaning and the lore term for momentum (e.g., "Three-Day Signal" = 3-day streak).                   |
| **Node**              | A server, hardware device, or infrastructure element in the ops context.                                                |
| **Faction War**       | The competitive meta-game between Defenders and Offensive operators.                                                    |
| **ProLab**            | The private cyber-range environment accessed via WireGuard tunnel.                                                      |
| **Callsign / Handle** | The operator's `operator_handle` - their leaderboard identity.                                                          |
| **TSEC{...}**         | The flag format used in operations missions (e.g., `TSEC{SIGNAL_ACQUIRED}`). Inspired by military SIGINT brevity codes. |
| **FLAG{...}**         | The flag format used in ProLab challenges. Distinguished from TSEC format.                                              |

### 10.2 Rank Name Quick Reference

RECRUIT → ANALYST → SPECIALIST → EXPERT → ARCHITECT → SENIOR_ARCHITECT → ELITE_OPERATOR → MASTER → LEGEND

### 10.3 Achievement Name Quick Reference (lore titles)

First Contact · Entry Analyst · Operational · Senior Analyst · Protocol Master · Network Specialist ·
Telecom Architect · Three-Day Signal · Week Warrior · Fortnight Operative · Monthly Operative ·
Two-Month Operative · Centurion Operator · Field Analyst · Specialist · Expert Operator · Architect ·
Senior Architect · Elite Operator · Legend · TSSA Foundations · TSS SS7 · GSM/2G Analyst · IMS Core
Operator · VoIP Security Auditor · LTE/EPC Security Engineer · 5G Fundamentals · 5G NR Specialist ·
PSTN Heritage Engineer · 5G Security Specialist · 5G SA Security Operator · LTE eNB Security Operator ·
Baseband Researcher · Lab Access Granted · Field Technician · Hands-On Expert · Foundations Capstone ·
GSM Field Operations · LTE Field Operations · VoIP Tactical Deployment · PSTN Heritage Operations ·
Foundations Clearance · Signaling Authority · 5G Integrity Specialist · Voice Backbone Tech ·
GSM Heritage Analyst · Railway Network Guard · Satellite Frontier Operative · Global Backbone Architect ·
EPC Security Architect · Mobile Hardware Analyst · Baseband Research Operator · LI Operations Certified ·
Signaling Analyst Certified · PSTN Heritage Analyst · 5G Security Engineer

### 10.4 Faction Name Quick Reference

- **DEFENDERS** - Cyan · Shield · "Protect telecom infrastructure."
- **OFFENSIVE** - Red · Crosshair · "Probe and exploit telecom vulnerabilities."

### 10.5 Ops Rank Quick Reference

Unranked → Signal Trainee → Field Analyst → RF Operator → Senior Operator → Expert Operator

### 10.6 Codebase Naming Notes for the Marketing Team

> ⚠ There is a naming split between human-facing titles and internal code identifiers. Use the
> **human-facing titles** in all marketing copy:

| Human-facing title (use in copy)            | Internal constant (do not publish) |
| ------------------------------------------- | ---------------------------------- |
| "Telecom Foundations"                       | `TELECOM_FOUNDATIONS` / `BASE`     |
| "Signaling Security Analyst" (career path)  | `SIGNALING_ANALYST` / `SIG-ANA`    |
| "Signaling Security Mastery"                | `SIGNALING_MASTERY` / `SIG`        |
| "5G Security Engineer" (career path)        | `5G_SECURITY_ENGINEER` / `5G-ENG`  |
| "TelcoSec Security Associate - Foundations" | cert code `TSSA-F`                 |
| "PSTN Security Foundations"                 | cert code `TSS-PSF`                |
| "Telecom Signaling Specialist - SS7"        | cert code `TSS-SS7`                |

The marketing site may reference "TSSA/TSSP/TSSE tracks" (older framing). The **implemented**
certification codes are **TSSA-F → TSS-\*** (Associate → Specialist). Align all new copy to the
implemented codes above.

### 10.7 Do Not Publish

The following must **never** appear in marketing, lore, or promotional material:

- Solved-flag answer tokens (e.g., the literal completed value of any `TSEC{...}` or `FLAG{...}`
  challenge answer - never publish the real flag strings)
- SHA-256 flag hash strings (64-character hex digests)
- Lab cryptographic material: UE key `K`, operator key `OPc`, WireGuard private keys
- Individual user data from the DB (XP totals, handles, countries) unless explicitly anonymized
- `verifyHash` values for any specific certified operator (these are personal credentials)

---

_Document generated from the TelcoSec platform codebase. Last updated 2026-06-11._
_Maintained in the root of the repository as `PROJECT.md`._
