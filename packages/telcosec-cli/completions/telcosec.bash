# bash completion for telcosec / telcochisel -*- shell-script -*-

__telcosec_interfaces() {
    local ifaces
    ifaces=$(command ls -1 /sys/class/net 2>/dev/null | grep -v '^lo$' | tr '\n' ' ')
    echo "$ifaces"
}

_telcosec() {
    local cur prev words cword
    _init_completion || return

    local commands="check status hardware hw devices search find docs doc documentation sdr 10g 10gbe network firmware bitstreams profile pkg package packages 5g-sa 5g 5gsa scan academy feedback review version completion help"

    if [[ $cword -eq 1 ]]; then
        COMPREPLY=( $(compgen -W "$commands" -- "$cur") )
        return 0
    fi

    local cmd="${words[1]}"

    case "$cmd" in
        pkg|package|packages)
            local pkg_subcommands="list info install remove check audit repo"
            local metapackages="base hardware sdr 2g-3g 4g 5g sim wireline pstn ue full"
            if [[ $cword -eq 2 ]]; then
                COMPREPLY=( $(compgen -W "$pkg_subcommands $metapackages" -- "$cur") )
            elif [[ $cword -eq 3 ]]; then
                case "${words[2]}" in
                    info|install|remove|purge|show)
                        COMPREPLY=( $(compgen -W "$metapackages" -- "$cur") )
                        ;;
                    list|ls)
                        COMPREPLY=( $(compgen -W "--json -j" -- "$cur") )
                        ;;
                    repo)
                        COMPREPLY=( $(compgen -W "status enable" -- "$cur") )
                        ;;
                esac
            fi
            ;;
        sdr)
            if [[ $cword -eq 2 ]]; then
                COMPREPLY=( $(compgen -W "status usb 10g firmware" -- "$cur") )
            elif [[ $cword -eq 3 && "${words[2]}" == "10g" ]]; then
                COMPREPLY=( $(compgen -W "status tune setup probe" -- "$cur") )
            elif [[ $cword -eq 4 && "${words[2]}" == "10g" && ( "${words[3]}" == "tune" || "${words[3]}" == "setup" ) ]]; then
                COMPREPLY=( $(compgen -W "$(__telcosec_interfaces)" -- "$cur") )
            elif [[ $cword -eq 5 && "${words[2]}" == "10g" && "${words[3]}" == "setup" ]]; then
                COMPREPLY=( $(compgen -W "x310-0 x310-1 n310-0 n310-1" -- "$cur") )
            fi
            ;;
        10g|10gbe|network)
            if [[ $cword -eq 2 ]]; then
                COMPREPLY=( $(compgen -W "status tune setup probe" -- "$cur") )
            elif [[ $cword -eq 3 && ( "${words[2]}" == "tune" || "${words[2]}" == "setup" ) ]]; then
                COMPREPLY=( $(compgen -W "$(__telcosec_interfaces)" -- "$cur") )
            elif [[ $cword -eq 4 && "${words[2]}" == "setup" ]]; then
                COMPREPLY=( $(compgen -W "x310-0 x310-1 n310-0 n310-1" -- "$cur") )
            fi
            ;;
        5g|5g-sa|5gsa)
            if [[ $cword -eq 2 ]]; then
                COMPREPLY=( $(compgen -W "start stop status add-sub" -- "$cur") )
            fi
            ;;
        profile)
            if [[ $cword -eq 2 ]]; then
                COMPREPLY=( $(compgen -W "lab field status" -- "$cur") )
            fi
            ;;
        scan)
            if [[ $cword -eq 2 ]]; then
                COMPREPLY=( $(compgen -W "sctp sip asleap" -- "$cur") )
            fi
            ;;
        completion)
            if [[ $cword -eq 2 ]]; then
                COMPREPLY=( $(compgen -W "bash zsh fish" -- "$cur") )
            fi
            ;;
        *)
            ;;
    esac

    return 0
}

complete -F _telcosec telcosec telcochisel
