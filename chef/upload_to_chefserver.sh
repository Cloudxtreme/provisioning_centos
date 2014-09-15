#!/bin/bash

COMMAND=$1

function command.help() {
    echo -e "\nUSAGE:\n"
    echo -e "\nupload_to_chefserver <COMMAND>"
    echo -e "\nCOMMAND is one of [help|roles|environments]"
    }

function command.roles() {
    for role in `ls roles/*.json`; do 
        knife role from file $role
    done
}

function command.environments() {
    for environment in `ls environments/*.json`; do 
        knife environment from file $environment
    done
}

function command.cookbooks(){
    for file in `ls cookbooks`; do
       knife cookbook upload $file
    done
}

command.$COMMAND
