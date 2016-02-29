#!/bin/bash

#********************************************************************************
# Copyright 2016 IBM
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#********************************************************************************

#############
# Colors    #
#############
export green='\e[0;32m'
export red='\e[0;31m'
export label_color='\e[0;33m'
export no_color='\e[0m' # No Color

function debugme() {
  [[ $DEBUG = 1 ]] && "$@" || :
}

# Install a suitable version of the CloudFoundary CLI (cf. https://github.com/cloudfoundry/cli/releases)
# Include the installed binary in $PATH
# Usage: install_cf
function install_cf() {  
  mkdir /tmp/cf
  __target_loc="${EXT_DIR}"

  if [[ -z ${which_cf} || -z $(cf --version | grep "version 6\.13\.0") ]]; then
    local __tmp=/tmp/cf$$.tgz
    wget -O ${__tmp} 'https://cli.run.pivotal.io/stable?release=linux64-binary&version=6.13.0&source=github-rel'
    tar -C ${__target_loc} -xzf ${__tmp}
    rm -f ${__tmp}
  fi
  export PATH=${__target_loc}:${PATH}
}

# Install the latest version of the ActiveDeploy CLI (from http://plugins.ng.bluemix.net)
# Usage: install_active_deploy
function install_active_deploy() {
  cf uninstall-plugin active-deploy || true
  if [[ -z $(cf list-plugin-repos | grep "bluemix") ]]; then
    cf add-plugin-repo bluemix http://plugins.ng.bluemix.net
  fi
  cf install-plugin active-deploy -r bluemix -f
}

set +e
#set $DEBUG to 1 for set -x output
if [[ -n $DEBUG ]]; then
  set -x # trace steps
fi

###############################
# Configure extension PATH    #
###############################
EXT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
debugme echo "EXT_DIR=$EXT_DIR"

#########################################
# Configure log file to store errors  #
#########################################
if [ -z "$ERROR_LOG_FILE" ]; then
    ERROR_LOG_FILE="${EXT_DIR}/errors.log"
    export ERROR_LOG_FILE
fi

################################
# get the extensions utilities #
################################
pushd . >/dev/null
cd $EXT_DIR
git_retry clone https://github.com/Osthanes/utilities.git utilities
popd >/dev/null

################################
# Source utilities sh files    #
################################
source ${EXT_DIR}/utilities/ice_utils.sh
source ${EXT_DIR}/utilities/logging_utils.sh

################################
# Setup pipeline slave         #
################################
if [[ -n "${INSTALL_CF}" ]]; then
  install_cf
fi
debugme which cf
debugme cf --version

install_active_deploy
debugme cf plugins

################################
# Install bc                   #
################################
sudo apt-get update &> /dev/null
sudo apt-get install -y bc

