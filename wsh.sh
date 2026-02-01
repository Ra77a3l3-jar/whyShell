#!/usr/bin/env bash

prompt() {
  echo "wsh$ "
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

        if [[ "$input" == "exit" ]]; then
            break
        fi

        # Execute
        eval "$input"
    done
}

main_loop
