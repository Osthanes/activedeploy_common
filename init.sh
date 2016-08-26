#!/bin/bash

#********************************************************************************
#   (c) Copyright 2016 IBM Corp.
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
export white='\e[0;37m'
export cyan='\e[0;36m'
export magenta='\e[0;35m'
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
    [[ -n ${USE_STAGE1_REPO} ]] && cf add-plugin-repo bluemix http://plugins.stage1.ng.bluemix.net || cf add-plugin-repo bluemix http://plugins.ng.bluemix.net
  fi
  cf install-plugin active-deploy -r bluemix -f
}

set +e
#set $DEBUG to 1 for set -x output
if [[ $DEBUG = 1 ]]; then
  set -x # trace steps
fi

###############################
# Configure extension PATH    #
###############################
if [[ -z $EXT_DIR ]]; then
  EXT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
  export EXT_DIR
  debugme echo "export EXT_DIR=$EXT_DIR"
fi

#########################################
# Configure log file to store errors  #
#########################################
if [ -z "$ERROR_LOG_FILE" ]; then
    ERROR_LOG_FILE="${EXT_DIR}/errors.log"
    export ERROR_LOG_FILE
fi

################################
# Setup pipeline slave         #
################################
if [[ -n "${INSTALL_CF}" ]]; then
  install_cf &> "/tmp/$$"
  (( $? )) && cat "/tmp/$$"
fi
debugme which cf
debugme cf --version

install_active_deploy &> "/tmp/$$"
(( $? )) && cat "/tmp/$$"
debugme cf plugins

################################
# Install bc                   #
################################
sudo apt-get update &> "/tmp/$$"
(( $? )) && cat "/tmp/$$"
sudo apt-get install -y bc &> "/tmp/$$"
(( $? )) && cat "/tmp/$$"

# git_retry clone -b ${GIT_BRANCH} https://github.com/${GIT_HOME}/update_service.git activedeploy &> /dev/null
