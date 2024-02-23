#!/usr/bin/env sh
#
# Entrypoint for twosix-bastion image
#

###
# Helper Functions and Setup
###

set -e
formatlog() {
  echo "$(date +%c): $1"
}

###
# Main Execution
###

# Exists to allow users to ssh to the container with a staged key on the T&E Range
formatlog "starting sshd service"
service ssh start

# Tailing and running indefinitely
formatlog "Tailing and running indefinitely"
tail -f /dev/null
