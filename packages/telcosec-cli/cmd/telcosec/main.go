// Command telcosec provides the unified operator CLI for TelcoChiselOS
// and standalone Linux systems.
package main

import (
	"fmt"
	"os"
	"os/exec"
	"strings"

	"github.com/TelcoSec-Tools/telcosec-cli/pkg/cellular"
	"github.com/TelcoSec-Tools/telcosec-cli/pkg/docs"
	"github.com/TelcoSec-Tools/telcosec-cli/pkg/network"
	"github.com/TelcoSec-Tools/telcosec-cli/pkg/sdr"
	"github.com/TelcoSec-Tools/telcosec-cli/pkg/search"
	"github.com/TelcoSec-Tools/telcosec-cli/pkg/telemetry"
)

var (
	// Version is populated at build time via -ldflags.
	Version   = "3.0.0"
	GitCommit = "development"
	BuildDate = "unknown"
)

func printBanner() {
	fmt.Print(telemetry.Cyan)
	fmt.Print(`  _____ _____ _     ____ ___   ____ _   _ ___ ____  _____ _     
 |_   _| ____| |   / ___/ _ \ / ___| | | |_ _/ ___|| ____| |    
   | | |  _| | |  | |  | | | | |   | |_| || |\___ \|  _| | |    
   | | | |___| |__| |__| |_| | |___|  _  || | ___) | |___| |___ 
   |_| |_____|_____\____\___/ \____|_| |_|___|____/|_____|_____|
`)
	fmt.Printf("%s%s          TelcoChisel Telecom Security Command Center v%s%s\n\n",
		telemetry.Reset, telemetry.Bold, Version, telemetry.Reset)
}

func printUsage() {
	printBanner()
	fmt.Printf(`Usage: telcosec <command> [options]
       telcochisel <command> [options]

Commands:
  check | status       Comprehensive system, kernel, hardware, and services audit
  hardware             Enumerate and probe attached SDRs, modems, and SIM readers
  search <query>       Search installed 88 tools and desktop launchers by keyword
  docs                 Open offline documentation & operator reference in browser
  sdr [action]         SDR drivers, USB & 10GbE management (status | usb | 10g | firmware)
  10g [action]         10Gbps network SDR interface optimization (status | tune | setup | probe)
  firmware             Inspect and manage offline SDR FPGA bitstreams (BladeRF, USRP)
  profile [mode]       Switch operational profiles (lab | field | status)
  5g-sa <action>       5G Standalone core & RAN manager (start | stop | status | add-sub)
  scan <protocol>      Interactive protocol assessment wizard (sctp | sip | asleap)
  academy              Access TelcoSec Academy interactive labs & credentials
  feedback             Community support channels & SourceForge review portal
  version              Show TelcoChiselOS release version and kernel details

Run 'telcosec <command> --help' for command-specific options.
`)
}

func main() {
	if len(os.Args) < 2 {
		printUsage()
		os.Exit(0)
	}

	cmd := strings.ToLower(os.Args[1])
	args := os.Args[2:]

	switch cmd {
	case "check", "status":
		printBanner()
		telemetry.RunAudit(os.Stdout)

	case "hardware", "hw", "devices":
		printBanner()
		sdr.ProbeHardware(os.Stdout)

	case "search", "find":
		if len(args) == 0 {
			fmt.Println("Usage: telcosec search <tool_name_or_keyword>")
			os.Exit(1)
		}
		query := strings.Join(args, " ")
		printBanner()
		tools, err := search.SearchTools(query, nil)
		if err != nil {
			fmt.Printf("Search failed: %v\n", err)
			os.Exit(1)
		}
		search.PrintResults(os.Stdout, query, tools)

	case "docs", "doc", "documentation":
		printBanner()
		docs.OpenDocs(os.Stdout)

	case "sdr":
		action := "status"
		if len(args) > 0 {
			action = strings.ToLower(args[0])
		}
		switch action {
		case "status":
			printBanner()
			fmt.Printf("%s=== Attached USB SDR Devices ===%s\n", telemetry.Bold, telemetry.Reset)
			devs := sdr.DetectUSBSDRs()
			if len(devs) == 0 {
				fmt.Printf("  %sNo USB SDR transceivers detected.%s\n", telemetry.Yellow, telemetry.Reset)
			} else {
				for _, d := range devs {
					fmt.Printf("  %s%-32s%s [USB ID: %s:%s]\n", telemetry.Green, d.Model, telemetry.Reset, d.VendorID, d.ProductID)
				}
			}

			fmt.Printf("\n%s=== Serial AT Cellular Modems ===%s\n", telemetry.Bold, telemetry.Reset)
			modems := sdr.DetectSerialModems()
			if len(modems) == 0 {
				fmt.Printf("  %sNo serial modems detected in /dev.%s\n", telemetry.Yellow, telemetry.Reset)
			} else {
				fmt.Printf("  %sFound %d modem(s): %s%s\n", telemetry.Green, len(modems), strings.Join(modems, " "), telemetry.Reset)
			}
			fmt.Println()

		case "usb":
			printBanner()
			mb := telemetry.GetUSBFSMemoryMB()
			fmt.Printf("%s=== USB Transceiver Buffer Tuning ===%s\n", telemetry.Bold, telemetry.Reset)
			if mb >= 500 {
				fmt.Printf("  usbfs_memory_mb = %s%d MB%s (Optimized for continuous high MSPS)\n\n", telemetry.Green, mb, telemetry.Reset)
			} else {
				fmt.Printf("  usbfs_memory_mb = %s%d MB%s (Recommends 1000 MB)\n", telemetry.Yellow, mb, telemetry.Reset)
				fmt.Println("  To optimize: sudo sh -c 'echo 1000 > /sys/module/usbcore/parameters/usbfs_memory_mb'")
				fmt.Println()
			}

		case "10g", "10gbe", "network":
			subArgs := args[1:]
			handle10GCommand(subArgs)

		case "firmware", "bitstreams":
			sdr.InspectBitstreams(os.Stdout)

		default:
			fmt.Printf("Unknown SDR action: %s\nUsage: telcosec sdr [status|usb|10g|firmware]\n", action)
			os.Exit(1)
		}

	case "10g", "10gbe", "network":
		handle10GCommand(args)

	case "firmware":
		printBanner()
		sdr.InspectBitstreams(os.Stdout)

	case "profile":
		mode := "status"
		if len(args) > 0 {
			mode = strings.ToLower(args[0])
		}
		if p, err := exec.LookPath("telcosec-profile"); err == nil {
			cmd := exec.Command(p, args...)
			cmd.Stdout = os.Stdout
			cmd.Stderr = os.Stderr
			_ = cmd.Run()
		} else {
			printBanner()
			curMode, desc := telemetry.GetProfileMode()
			if mode == "status" {
				fmt.Printf("Active Profile Mode: %s\n", desc)
			} else if mode == "lab" {
				fmt.Println("Switching to Lab Mode (unrestricted packet crafting, rp_filter=0)...")
				_ = exec.Command("sudo", "sysctl", "-w", "net.ipv4.conf.all.rp_filter=0").Run()
				fmt.Printf("Profile switched: %s\n", curMode)
			} else if mode == "field" {
				fmt.Println("Switching to Field Mode (strict reverse path filtering, rp_filter=1)...")
				_ = exec.Command("sudo", "sysctl", "-w", "net.ipv4.conf.all.rp_filter=1").Run()
				fmt.Printf("Profile switched: %s\n", curMode)
			}
		}

	case "5g", "5g-sa", "5gsa":
		action := "status"
		if len(args) > 0 {
			action = strings.ToLower(args[0])
		}
		switch action {
		case "start":
			_ = cellular.StartCore(os.Stdout)
		case "stop":
			_ = cellular.StopCore(os.Stdout)
		case "status":
			_ = cellular.StatusCore(os.Stdout)
		case "add-sub":
			imsi := ""
			k := ""
			opc := ""
			if len(args) > 1 {
				imsi = args[1]
			}
			if len(args) > 2 {
				k = args[2]
			}
			if len(args) > 3 {
				opc = args[3]
			}
			_ = cellular.AddSubscriber(os.Stdout, imsi, k, opc)
		default:
			fmt.Println("Usage: telcosec 5g-sa {start|stop|status|add-sub [imsi] [k] [opc]}")
			os.Exit(1)
		}

	case "scan":
		if len(args) == 0 {
			fmt.Println("Usage: telcosec scan {sctp|sip|asleap} [target options]")
			os.Exit(1)
		}
		proto := strings.ToLower(args[0])
		protoArgs := args[1:]
		switch proto {
		case "sctp":
			fmt.Printf("%s=== SCTP Signaling Scanner (sctpscan) ===%s\n", telemetry.Bold, telemetry.Reset)
			if bin, err := exec.LookPath("sctpscan"); err == nil {
				cmd := exec.Command(bin, protoArgs...)
				cmd.Stdout = os.Stdout
				cmd.Stderr = os.Stderr
				cmd.Stdin = os.Stdin
				_ = cmd.Run()
			} else {
				fmt.Println("sctpscan not found on system.")
			}
		case "sip":
			fmt.Printf("%s=== SIP Scanner (SIPVicious) ===%s\n", telemetry.Bold, telemetry.Reset)
			bin := "sipvicious_svmap"
			if p, err := exec.LookPath("sipvicious_svmap"); err == nil {
				bin = p
			} else if p, err := exec.LookPath("svmap"); err == nil {
				bin = p
			} else {
				fmt.Println("SIPVicious svmap not found on system.")
				return
			}
			cmd := exec.Command(bin, protoArgs...)
			cmd.Stdout = os.Stdout
			cmd.Stderr = os.Stderr
			cmd.Stdin = os.Stdin
			_ = cmd.Run()
		case "asleap":
			fmt.Printf("%s=== Asleap PPPoE / MS-CHAPv2 Cracker ===%s\n", telemetry.Bold, telemetry.Reset)
			if bin, err := exec.LookPath("asleap"); err == nil {
				cmd := exec.Command(bin, protoArgs...)
				cmd.Stdout = os.Stdout
				cmd.Stderr = os.Stderr
				cmd.Stdin = os.Stdin
				_ = cmd.Run()
			} else {
				fmt.Println("asleap not found on system.")
			}
		default:
			fmt.Println("Usage: telcosec scan {sctp|sip|asleap} [target options]")
		}

	case "academy":
		docs.OpenAcademy(os.Stdout)

	case "feedback", "review", "reviews":
		docs.OpenFeedback(os.Stdout)

	case "version", "-v", "--version":
		kver, _ := telemetry.GetKernelVersion()
		fmt.Printf("TelcoSec Unified Operator CLI v%s (%s, built %s)\n", Version, GitCommit, BuildDate)
		fmt.Printf("Platform: Linux (%s)\n", kver)

	case "help", "-h", "--help":
		printUsage()

	default:
		fmt.Printf("Unknown command: %s\n\n", cmd)
		printUsage()
		os.Exit(1)
	}
}

func handle10GCommand(args []string) {
	action := "status"
	if len(args) > 0 {
		action = strings.ToLower(args[0])
	}

	switch action {
	case "status":
		printBanner()
		network.PrintStatus(os.Stdout)

	case "tune":
		if len(args) < 2 {
			fmt.Println("Usage: telcosec 10g tune <interface_name>")
			os.Exit(1)
		}
		iface := args[1]
		_ = network.TuneInterface(os.Stdout, iface)

	case "setup":
		if len(args) < 2 {
			fmt.Println("Usage: telcosec 10g setup <interface_name> [preset: x310-0|x310-1|n310-0|n310-1]")
			os.Exit(1)
		}
		iface := args[1]
		preset := "x310-0"
		if len(args) > 2 {
			preset = args[2]
		}
		_ = network.SetupInterface(os.Stdout, iface, preset)

	case "probe":
		ip := ""
		if len(args) > 1 {
			ip = args[1]
		}
		printBanner()
		network.ProbeNetwork(os.Stdout, ip)

	default:
		fmt.Printf("Unknown 10G action: %s\nUsage: telcosec 10g [status|tune|setup|probe]\n", action)
		os.Exit(1)
	}
}
