#!/bin/sh

# Auto-start nwipe on the first interactive console shell
if [ -z "$SSH_CONNECTION" ] && [ "$(tty 2>/dev/null)" = "/dev/tty1" ]; then
    if command -v nwipe >/dev/null 2>&1; then
        exec nwipe
    fi
fi
