#!/usr/bin/env bash

prompt() {
  echo "wsh$ "
}

builtin_cd() {
    local target="${1:-$HOME}"
    if cd "$target" 2>/dev/null; then
        return 0
    else
        echo "wsh: cd: $target: No such file or directory" >&2
        return 1
    fi
}

builtin_help() {
    cat << EOF
    - A Bash Shell in Bash

    cd [directory]  Change to directory
    pwd             Print directory
    exit [code]     Exit shell
    help            Show instructions

Any standard command as well!
EOF
}

is_builtin() {
    case "$1" in
        cd|exit|help)
            return 0
            ;;
        *)
            return 1
            ;;
    esac        
}

execute_builtin() {
    local cmd="$1"
    shift

    case "$cmd" in
        cd)
            builtin_cd "$@"
            ;;
        exit)
            exit "${1:-0}"
            ;;
        help)
            builtin_help
            ;;
    esac
}

main_loop() {
    local input
    local prompt

    while true; do
        prompt=$(prompt)

        if ! read -e -p "$prompt" input; then
            echo
            echo "exit"
            break
        fi

        # Skip empty input
        if [[ -z "$input" ]]; then
            continue
        fi

        # Parse input
        read -ra ARGS <<< "$input"
        local cmd="${ARGS[0]}"

        if is_builtin "$cmd"; then
            execute_builtin "${ARGS[@]}"
        else
            # Execute
            eval "$input"
        fi
    done
}

main_loop
