#!/bin/sh

VM="mmurillo-vagrant-centos"

vagrant destroy --force
yes | knife client delete $VM
yes | knife node delete $VM
