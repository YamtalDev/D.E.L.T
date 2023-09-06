#!/bin/bash

DISCORD_PID=$(pgrep Discord)
if [[ -n $DISCORD_PID ]]; then
  kill -15 $DISCORD_PID
  sleep 5
  kill -9 $DISCORD_PID
fi
