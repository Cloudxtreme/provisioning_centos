#!/bin/bash

echo -e "\nWARNING! Going to install the ureport submodules in this git repo!!!\n"

function install.submodule() {
    local repo=$1
    local branch=$2
    local install_path=$3

    echo "git submodule add -b ${branch} ${repo} ${install_path} ..."
    git submodule add -b ${branch} ${repo} ${install_path}


}

function install.submodules() {
    local branch=$1
    echo -e "\nInstalling the submodules on branch [${branch}] now...\n"

    install.submodule "git://github.com/unicefuganda/django-eav.git" "${branch}" "ureport_project/django_eav"
    install.submodule "git://github.com/unicefuganda/django-taggit.git" "${branch}" "ureport_project/django_taggit"
    install.submodule "git://github.com/unicefuganda/monitor_src.git" "${branch}" "ureport_project/qos_monitor"

    install.submodule "git://github.com/unicefuganda/rapidsms.git" "${branch}" "ureport_project/rapidsms"
    install.submodule "git://github.com/unicefuganda/rapidsms-auth.git" "${branch}" "ureport_project/rapidsms_auth"
    install.submodule "git://github.com/unicefuganda/rapidsms-contact.git" "${branch}" "ureport_project/rapidsms_contact"
    install.submodule "git://github.com/unicefuganda/rapidsms-generic.git" "${branch}" "ureport_project/rapidsms_generic"
    install.submodule "git://github.com/unicefuganda/rapidsms-geoserver.git" "${branch}" "ureport_project/rapidsms_geoserver"
    install.submodule "git://github.com/unicefuganda/rapidsms-httprouter.git" "${branch}" "ureport_project/rapidsms_httprouter_src"
    install.submodule "git://github.com/unicefuganda/rapidsms-message-classifier.git" "${branch}" "ureport_project/rapidsms_message_classifier"
    install.submodule "git@github.com:Senescyt/rapidsms-polls.git" "${branch}" "ureport_project/rapidsms_polls"
    install.submodule "git://github.com/unicefuganda/rapidsms-script.git" "${branch}" "ureport_project/rapidsms_script"
    install.submodule "git://github.com/unicefuganda/rapidsms-tracking.git" "${branch}" "ureport_project/rapidsms_tracking"
    install.submodule "git://github.com/unicefuganda/rapidsms-uganda-common.git" "${branch}" "ureport_project/rapidsms_uganda_common"
    install.submodule "git://github.com/unicefuganda/rapidsms-uganda-ussd.git" "${branch}" "ureport_project/rapidsms_uganda_ussd"
    install.submodule "git://github.com/unicefuganda/rapidsms-unregister.git" "${branch}" "ureport_project/rapidsms_unregister"
    install.submodule "git@github.com:Senescyt/rapidsms-ureport.git" "${branch}" "ureport_project/rapidsms_ureport"
    install.submodule "git://github.com/Senescyt/rapidsms-xforms.git" "${branch}" "ureport_project/rapidsms_xforms_src"


    echo -e "\nDone.\n"
}

read -r -p "Are you sure? [Y/n] " response
case $response in
    [yY][eE][sS]|[yY])
        install.submodules "south_sudan"
        ;;
    *)
        echo -e "\nOk, don't worry, nothing happened.\n"
        ;;
esac

git submodule status
