#!/usr/bin/env bash
if ! pgrep ssh-agent > /dev/null; then
    eval $(ssh-agent) > /dev/null
fi
