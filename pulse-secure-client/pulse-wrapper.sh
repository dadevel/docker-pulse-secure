#!/usr/bin/env bash
set -eu

tail -f ~/.pulse_secure/pulse/pulsesvc.log &
/usr/local/pulse/pulseUi &
wait $!

