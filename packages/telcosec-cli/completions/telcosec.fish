# fish completion for telcosec / telcochisel

function __telcosec_interfaces
    command ls -1 /sys/class/net 2>/dev/null | string match -v 'lo'
end

function __telcosec_using_subcommand
    set -l cmd (commandline -opc)
    if [ (count $cmd) -eq 1 ]
        return 1
    end
    for arg in $argv
        if contains -- $arg $cmd
            return 0
        end
    end
    return 1
end

complete -c telcosec -f
complete -c telcochisel -f

# Main Commands
complete -c telcosec -n "not __telcosec_using_subcommand check status hardware search docs sdr 10g firmware profile 5g-sa scan academy feedback completion version help" -a check -d "Run comprehensive pre-flight healthcheck"
complete -c telcosec -n "not __telcosec_using_subcommand check status hardware search docs sdr 10g firmware profile 5g-sa scan academy feedback completion version help" -a status -d "Display detailed kernel, PAM limits, and service telemetry"
complete -c telcosec -n "not __telcosec_using_subcommand check status hardware search docs sdr 10g firmware profile 5g-sa scan academy feedback completion version help" -a hardware -d "Enumerate and probe attached SDRs, modems, and SIM readers"
complete -c telcosec -n "not __telcosec_using_subcommand check status hardware search docs sdr 10g firmware profile 5g-sa scan academy feedback completion version help" -a search -d "Search installed 88 tools and desktop launchers by keyword"
complete -c telcosec -n "not __telcosec_using_subcommand check status hardware search docs sdr 10g firmware profile 5g-sa scan academy feedback completion version help" -a docs -d "Open offline documentation in browser"
complete -c telcosec -n "not __telcosec_using_subcommand check status hardware search docs sdr 10g firmware profile 5g-sa scan academy feedback completion version help" -a sdr -d "SDR drivers, USB and 10GbE transceiver management"
complete -c telcosec -n "not __telcosec_using_subcommand check status hardware search docs sdr 10g firmware profile 5g-sa scan academy feedback completion version help" -a 10g -d "10Gbps network SDR interface optimization"
complete -c telcosec -n "not __telcosec_using_subcommand check status hardware search docs sdr 10g firmware profile 5g-sa scan academy feedback completion version help" -a firmware -d "Inspect and manage offline SDR FPGA bitstreams"
complete -c telcosec -n "not __telcosec_using_subcommand check status hardware search docs sdr 10g firmware profile pkg 5g-sa scan academy feedback completion version help" -a profile -d "Switch operational profiles (lab vs field)"
complete -c telcosec -n "not __telcosec_using_subcommand check status hardware search docs sdr 10g firmware profile pkg 5g-sa scan academy feedback completion version help" -a pkg -d "Official modular metapackage manager"
complete -c telcosec -n "not __telcosec_using_subcommand check status hardware search docs sdr 10g firmware profile pkg 5g-sa scan academy feedback completion version help" -a 5g-sa -d "5G Standalone core and RAN lifecycle manager"
complete -c telcosec -n "not __telcosec_using_subcommand check status hardware search docs sdr 10g firmware profile pkg 5g-sa scan academy feedback completion version help" -a scan -d "Interactive protocol assessment wizard"
complete -c telcosec -n "not __telcosec_using_subcommand check status hardware search docs sdr 10g firmware profile pkg 5g-sa scan academy feedback completion version help" -a academy -d "Access TelcoSec Academy interactive labs"
complete -c telcosec -n "not __telcosec_using_subcommand check status hardware search docs sdr 10g firmware profile pkg 5g-sa scan academy feedback completion version help" -a feedback -d "Community support and SourceForge reviews"
complete -c telcosec -n "not __telcosec_using_subcommand check status hardware search docs sdr 10g firmware profile pkg 5g-sa scan academy feedback completion version help" -a completion -d "Generate shell completion script"
complete -c telcosec -n "not __telcosec_using_subcommand check status hardware search docs sdr 10g firmware profile pkg 5g-sa scan academy feedback completion version help" -a version -d "Show release version and kernel details"

# Subcommands
complete -c telcosec -n "__telcosec_using_subcommand pkg" -a "list info install remove check repo base hardware sdr 2g-3g 4g 5g sim wireline ue full"
complete -c telcosec -n "__telcosec_using_subcommand sdr" -a "status usb 10g firmware"
complete -c telcosec -n "__telcosec_using_subcommand 10g" -a "status tune setup probe"
complete -c telcosec -n "__telcosec_using_subcommand 5g-sa" -a "start stop status add-sub"
complete -c telcosec -n "__telcosec_using_subcommand profile" -a "status lab field"
complete -c telcosec -n "__telcosec_using_subcommand scan" -a "sctp sip asleap"
complete -c telcosec -n "__telcosec_using_subcommand completion" -a "bash zsh fish"
