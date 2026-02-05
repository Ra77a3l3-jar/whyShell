#!/usr/bin/env bash

declare -a HISTORY_ARRAY=()

prompt() {
    echo "wsh$ "
}

add_to_history() {
    local cmd="$1"
    if [[ -n "$cmd" ]]; then
        HISTORY_ARRAY+=("$cmd")
        history -s "$cmd"
    fi
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

builtin_history() {
    local i=1
    for cmd in "${HISTORY_ARRAY[@]}"; do
        echo "$i" "$cmd"
        ((i++))
    done
}

is_builtin() {
    case "$1" in
        cd|exit|help|history)
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
        history)
            builtin_history
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

        add_to_history "$input"

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
