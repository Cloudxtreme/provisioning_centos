#!/bin/bash

tail -f /var/log/kannel/kannel.log | grep 'source_addr\|destination_addr\|short_message'
