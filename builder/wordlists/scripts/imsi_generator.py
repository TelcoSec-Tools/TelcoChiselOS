#!/usr/bin/env python3
# TelcoSec Academy - https://app.telcosec.net/

import argparse
import random
import sys

def generate_imsis(mcc, mnc, start_msin, count, randomize=False):
    mcc = mcc.strip()
    mnc = mnc.strip()
    
    # E.212 standard: IMSI is 15 digits total.
    # MSIN length = 15 - len(MCC) - len(MNC)
    msin_len = 15 - len(mcc) - len(mnc)
    if msin_len <= 0:
        raise ValueError("Invalid MCC/MNC combination length (must be less than 15 digits total)")
        
    imsis = []
    
    if randomize:
        # Generate random MSINs
        max_val = 10**msin_len - 1
        for _ in range(count):
            msin_val = random.randint(0, max_val)
            msin_str = f"{msin_val:0{msin_len}d}"
            imsis.append(f"{mcc}{mnc}{msin_str}")
    else:
        # Generate sequential MSINs
        start_val = int(start_msin)
        max_val = 10**msin_len - 1
        for i in range(count):
            msin_val = (start_val + i) % (max_val + 1)
            msin_str = f"{msin_val:0{msin_len}d}"
            imsis.append(f"{mcc}{mnc}{msin_str}")
            
    return imsis

def main():
    parser = argparse.ArgumentParser(
        description="TelcoSec IMSI Generator - Generate valid IMSIs for lab simulation & routing tests."
    )
    parser.add_argument("--mcc", required=True, help="Mobile Country Code (e.g. 262, 310)")
    parser.add_argument("--mnc", required=True, help="Mobile Network Code (e.g. 01, 410)")
    parser.add_argument("--start", default="0", help="Start of MSIN sequence (default: 0)")
    parser.add_argument("--count", type=int, default=10, help="Number of IMSIs to generate (default: 10)")
    parser.add_argument("--random", action="store_true", help="Generate randomized MSINs instead of sequential")
    parser.add_argument("--output", help="Output file to write IMSIs (default: stdout)")
    
    args = parser.parse_args()
    
    try:
        imsis = generate_imsis(args.mcc, args.mnc, args.start, args.count, args.random)
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)
        
    if args.output:
        with open(args.output, "w", encoding="utf-8") as f:
            f.write("# TelcoSec Academy - https://app.telcosec.net/\n\n")
            for imsi in imsis:
                f.write(imsi + "\n")
        print(f"Successfully generated {len(imsis)} IMSIs to {args.output}")
    else:
        print("# TelcoSec Academy - https://app.telcosec.net/\n")
        for imsi in imsis:
            print(imsi)

if __name__ == "__main__":
    main()