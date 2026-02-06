#!/usr/bin/env bash

SHELL_NAME="whs"
MAX_HISTORY=1000
HISTORY_FILE="${HOME}/.config/${SHELL_NAME}/history"

LAST_EXIT_CODE=0

declare -a HISTORY_ARRAY=()
declare -a SHELL_VARS=()

# Setup shell after startup
init_shell() {
    local history_dir
    history_dir=$(dirname "$HISTORY_FILE")
    mkdir -p "$history_dir"

    # Load histury
    if [[ -f "$HISTORY_FILE" ]]; then
        mapfile -t HISTORY_ARRAY < "$HISTORY_FILE"
        history -r "$HISTORY_FILE"
    fi
}

prompt() {
    if [[ $LAST_EXIT_CODE -eq 0 ]]; then
        echo -e "\e[32mwhy\e[0m\e[34mSh\e[0m \e[36m❯\e[0m "
    else
        echo -e "\e[32mwhy\e[0m\e[34mSh\e[0m \e[31m❯\e[0m "
    fi
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

cd [dir]  Change to directory
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

builtin_set() {
    if [[ $# -eq 0 ]]; then
        for var in "${SHELL_VARS[@]}"; do
            echo "$var=${SHELL_VARS[$var]}"
        done | sort
    elif [[ $# -eq 2 ]]; then
        SHELL_VARS["$1"]="$2"
    else
        echo "set: usage: set [var_name] [value]" >&2
        return 1
    fi
}

is_builtin() {
    case "$1" in
        cd|exit|help|history|set)
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
        set)
            builtin_set "$@"
            ;;
    esac
}

parse_and_execute() {

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
            LAST_EXIT_CODE=0
            continue
        fi

        add_to_history "$input"

        # TODO add parse and execute func

        # Parse input
        read -ra ARGS <<< "$input"
        local cmd="${ARGS[0]}"

        if is_builtin "$cmd"; then
            execute_builtin "${ARGS[@]}"
            LAST_EXIT_CODE=$?
        else
            # Execute
            eval "$input"
            LAST_EXIT_CODE=$?
        fi
    done
}

init_shell
main_loop
