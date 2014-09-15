#!/bin/bash

cd /home/ureport/SMPPSim
nohup ./startsmppsim.sh > /dev/null 2> /dev/null < /dev/null &
tail -f /var/log/smppsim/smppsim-0.log.0

