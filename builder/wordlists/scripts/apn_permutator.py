#!/usr/bin/env python3
# TelcoSec Academy - https://app.telcosec.net/

import argparse
import sys

def generate_permutations(operator, mcc, mnc):
    operator = operator.lower().strip()
    mcc = mcc.strip()
    mnc = mnc.strip()
    
    # Pad mnc if single digit (though MCC/MNC are typically 3 and 2/3 digits respectively)
    if len(mnc) == 1:
        mnc = "0" + mnc
        
    domains = [
        "gprs", "geogprs", "lte", "3gppnetwork.org", "ipv6", "m2m", "iot", "vpn",
        "telekom", "vodafone", "orange", "claro", "t-mobile", "att", "verizon"
    ]
    
    suffixes = [
        "", "lte", "ims", "mms", "data", "internet", "broadband", "wap",
        "web", "secure", "public", "private", "m2m", "iot", "volte"
    ]
    
    permutations = set()
    
    # Operator name direct & combined
    permutations.add(operator)
    for s in suffixes:
        if s:
            permutations.add(f"{operator}.{s}")
            permutations.add(f"{s}.{operator}")
            permutations.add(f"{operator}-{s}")
            permutations.add(f"{s}-{operator}")
            
    # Standard 3GPP formats
    permutations.add(f"mnc{mnc}.mcc{mcc}.gprs")
    permutations.add(f"internet.mnc{mnc}.mcc{mcc}.gprs")
    permutations.add(f"ims.mnc{mnc}.mcc{mcc}.gprs")
    permutations.add(f"mms.mnc{mnc}.mcc{mcc}.gprs")
    permutations.add(f"wap.mnc{mnc}.mcc{mcc}.gprs")
    permutations.add(f"sos.mnc{mnc}.mcc{mcc}.gprs")
    
    # EPC (Evolved Packet Core) specific formats
    permutations.add(f"apn.epc.mnc{mnc}.mcc{mcc}.3gppnetwork.org")
    permutations.add(f"ims.epc.mnc{mnc}.mcc{mcc}.3gppnetwork.org")
    permutations.add(f"sos.epc.mnc{mnc}.mcc{mcc}.3gppnetwork.org")
    
    # Common variations
    for s in suffixes:
        if s:
            permutations.add(f"{s}.mnc{mnc}.mcc{mcc}.gprs")
            permutations.add(f"apn.{s}.epc.mnc{mnc}.mcc{mcc}.3gppnetwork.org")
            
    return sorted(list(permutations))

def main():
    parser = argparse.ArgumentParser(
        description="TelcoSec APN Permutator - Generate cellular Access Point Name permutations."
    )
    parser.add_argument("--operator", required=True, help="Operator name (e.g. telekom, vodafone, att)")
    parser.add_argument("--mcc", required=True, help="Mobile Country Code (e.g. 262, 310)")
    parser.add_argument("--mnc", required=True, help="Mobile Network Code (e.g. 01, 410)")
    parser.add_argument("--output", help="Output file to write permutations (default: stdout)")
    
    args = parser.parse_args()
    
    perms = generate_permutations(args.operator, args.mcc, args.mnc)
    
    if args.output:
        with open(args.output, "w", encoding="utf-8") as f:
            f.write("# TelcoSec Academy - https://app.telcosec.net/\n\n")
            for p in perms:
                f.write(p + "\n")
        print(f"Successfully wrote {len(perms)} APN permutations to {args.output}")
    else:
        print("# TelcoSec Academy - https://app.telcosec.net/\n")
        for p in perms:
            print(p)

if __name__ == "__main__":
    main()