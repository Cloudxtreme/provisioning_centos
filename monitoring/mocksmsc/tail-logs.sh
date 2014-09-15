#!/bin/bash

tail -f /var/log/smppsim/smppsim-0.log.0 | grep 'short_message\|dest_addr'
