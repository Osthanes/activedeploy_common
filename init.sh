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


# Install a CloudFoundary and ActiveDeploy CLIs; provide debugging information
# Usage: slave_setup
function slave_setup() {
  install_cf
  which cf
  cf --version
  install_active_deploy

  cf plugins
  cf active-deploy-service-info
}

installwithpython276() {
    echo "Installing Python 2.7.6"
    sudo apt-get update &> /dev/null
    sudo apt-get -y install python2.7.6 &> /dev/null
    python --version
    wget --no-check-certificate https://bootstrap.pypa.io/get-pip.py &> /dev/null
    python get-pip.py --user &> /dev/null
    export PATH=$PATH:~/.local/bin
    if [ -f icecli-3.0.zip ]; then
        debugme echo "there was an existing icecli.zip"
        debugme ls -la
        rm -f icecli-3.0.zip
    fi
    wget https://static-ice.ng.bluemix.net/icecli-3.0.zip &> /dev/null
    pip install --user icecli-3.0.zip > cli_install.log 2>&1
    debugme cat cli_install.log
}

installwithpython27() {
    echo "Installing Python 2.7"
    sudo apt-get update &> /dev/null
    sudo apt-get -y install python2.7 &> /dev/null
    python --version
    wget --no-check-certificate https://bootstrap.pypa.io/get-pip.py &> /dev/null
    python get-pip.py --user &> /dev/null
    export PATH=$PATH:~/.local/bin
    if [ -f icecli-3.0.zip ]; then
        debugme echo "there was an existing icecli.zip"
        debugme ls -la
        rm -f icecli-3.0.zip
    fi
    wget https://static-ice.ng.bluemix.net/icecli-3.0.zip &> /dev/null
    pip install --user icecli-3.0.zip > cli_install.log 2>&1
    debugme cat cli_install.log
}

installwithpython34() {
    curl -kL http://xrl.us/pythonbrewinstall | bash
    source $HOME/.pythonbrew/etc/bashrc
    sudo apt-get install zlib1g-dev libexpat1-dev libdb4.8-dev libncurses5-dev libreadline6-dev
    sudo apt-get update &> /dev/null
    debugme pythonbrew list -k
    echo "Installing Python 3.4.1"
    pythonbrew install 3.4.1 &> /dev/null
    debugme cat /home/jenkins/.pythonbrew/log/build.log
    pythonbrew switch 3.4.1
    python --version
    echo "Installing pip"
    wget --no-check-certificate https://bootstrap.pypa.io/get-pip.py &> /dev/null
    python get-pip.py --user
    export PATH=$PATH:~/.local/bin
    which pip
    echo "Installing ice cli"
    wget https://static-ice.ng.bluemix.net/icecli-3.0.zip &> /dev/null
    wget https://static-ice.ng.bluemix.net/icecli-3.0.zip
    pip install --user icecli-3.0.zip > cli_install.log 2>&1
    debugme cat cli_install.log
}

installwithpython277() {
    pushd $EXT_DIR >/dev/null
    echo "Installing Python 2.7.7"
    curl -kL http://xrl.us/pythonbrewinstall | bash
    source $HOME/.pythonbrew/etc/bashrc

    sudo apt-get update &> /dev/null
    sudo apt-get build-dep python2.7
    sudo apt-get install zlib1g-dev
    debugme pythonbrew list -k
    echo "Installing Python 2.7.7"
    pythonbrew install 2.7.7 --no-setuptools &> /dev/null
    debugme cat /home/jenkins/.pythonbrew/log/build.log
    pythonbrew switch 2.7.7
    python --version
    echo "Installing pip"
    wget --no-check-certificate https://bootstrap.pypa.io/get-pip.py &> /dev/null
    python get-pip.py --user &> /dev/null
    debugme pwd
    debugme ls
    popd >/dev/null
    pip remove requests
    pip install --user -U requests
    pip install --user -U pip
    export PATH=$PATH:~/.local/bin
    which pip
    echo "Installing ice cli"
    wget https://static-ice.ng.bluemix.net/icecli-3.0.zip &> /dev/null
    pip install --user icecli-3.0.zip > cli_install.log 2>&1
    debugme cat cli_install.log
}

installwithpython3() {

    sudo apt-get update &> /dev/null
    sudo apt-get upgrade &> /dev/null
    sudo apt-get -y install python3 &> /dev/null
    python3 --version
    echo "installing pip"
    wget --no-check-certificate https://bootstrap.pypa.io/get-pip.py
    python3 get-pip.py --user &> /dev/null
    export PATH=$PATH:~/.local/bin
    which pip
    echo "installing ice cli"

    wget https://static-ice.ng.bluemix.net/icecli-3.0.zip
    pip install --user icecli-3.0.zip > cli_install.log 2>&1
    debugme cat cli_install.log
}

if [[ $DEBUG = 1 ]]; then
    export ICE_ARGS="--verbose"
else
    export ICE_ARGS=""
fi

set +e
set -x


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

#################################
# Source git_util sh file       #
#################################
source ${EXT_DIR}/git_util.sh

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

######################
# Install ICE CLI    #
######################
echo "Installing IBM Container Service CLI"
ice help &> /dev/null
RESULT=$?
if [ $RESULT -ne 0 ]; then
#    installwithpython3
#    installwithpython27
    installwithpython276
#    installwithpython277
#    installwithpython34
    ice help &> /dev/null
    RESULT=$?
    if [ $RESULT -ne 0 ]; then
        echo -e "${red}Failed to install IBM Containers CLI ${no_color}" | tee -a "$ERROR_LOG_FILE"
        debugme python --version
        ${EXT_DIR}/print_help.sh
        ${EXT_DIR}/utilities/sendMessage.sh -l bad -m "Failed to install IBM Container Service CLI. $(get_error_info)"
        exit $RESULT
    fi
    echo -e "${label_color}Successfully installed IBM Containers CLI ${no_color}"
fi

# Setup pipeline slave
slave_setup
debugme cf apps

##########################################
# login_using_bluemix_user_password      #
##########################################
cf_login(){
    if [ -z "$BLUEMIX_USER" ]; then 
        echo -e "${red} In order to login with ice login command, the Bluemix user id is required ${no_color}" | tee -a "$ERROR_LOG_FILE"
        echo -e "${red} Please set BLUEMIX_USER on environment ${no_color}" | tee -a "$ERROR_LOG_FILE"
        return 1
    fi 
    if [ -z "$BLUEMIX_PASSWORD" ]; then 
        echo -e "${red} In order to login with ice login command, the Bluemix password is required ${no_color}" | tee -a "$ERROR_LOG_FILE"
        echo -e "${red} Please set BLUEMIX_PASSWORD as an environment property environment ${no_color}" | tee -a "$ERROR_LOG_FILE"
        return 1
    fi 
    if [ -z "$BLUEMIX_ORG" ]; then 
        export BLUEMIX_ORG=$BLUEMIX_USER
        echo -e "${label_color} Using ${BLUEMIX_ORG} for Bluemix organization, please set BLUEMIX_ORG on the environment if you wish to change this. ${no_color} "
    fi 
    if [ -z "$BLUEMIX_SPACE" ]; then
        export BLUEMIX_SPACE="dev"
        echo -e "${label_color} Using ${BLUEMIX_SPACE} for Bluemix space, please set BLUEMIX_SPACE on the environment if you wish to change this. ${no_color} "
    fi 
    echo -e "${label_color}Logging on with Bluemix userid and Bluemix password${no_color}"
    echo "BLUEMIX_USER: ${BLUEMIX_USER}"
    echo "BLUEMIX_SPACE: ${BLUEMIX_SPACE}"
    echo "BLUEMIX_ORG: ${BLUEMIX_ORG}"
    echo "BLUEMIX_PASSWORD: xxxxx"
    echo ""

    local RC=0
    local retries=0
    while [ $retries -lt 5 ]; do 
        debugme echo "login command: cf login -u ${BLUEMIX_USER} -p xxxxxx -o ${BLUEMIX_ORG} -s ${BLUEMIX_SPACE} -a ${BLUEMIX_API_HOST}"
        cf login -u ${BLUEMIX_USER} -p ${BLUEMIX_PASSWORD} -o ${BLUEMIX_ORG} -s ${BLUEMIX_SPACE} -a ${BLUEMIX_API_HOST} 2> /dev/null
        RC=$?
        if [ ${RC} -eq 0 ] || [ ${RC} -eq 2 ]; then
            break
        fi
        echo -e "${label_color}Failed to login to IBM Bluemix. Sleep 20 sec and try again.${no_color}"
        sleep 20
        retries=$(( $retries + 1 ))   
    done


    if [ $RC -eq 0 ]; then
        echo -e "${label_color}Logged in into IBM Bluemix using cf login command${no_color}"
    else
        echo -e "${red}Failed to log in into IBM Bluemix${no_color}. cf login command returns error code ${RC}" | tee -a "$ERROR_LOG_FILE"
    fi 
}

if [[ ${TARGET_PLATFORM} = "Container" ]]; then
    ################################
    # Login to Container Service   #
    ################################
    login_to_container_service
    RESULT=$?
    if [ $RESULT -ne 0 ]; then
        exit $RESULT
    fi
elif [[ ${TARGET_PLATFORM} = "VM" ]]; then
  echo "VMs are not supported"
  exit 1
elif [[ ${TARGET_PLATFORM} = "CloudFoundry" ]]; then
    ################################
    # Login to Bluemix
    ################################
    cf_login
    RESULT=$?
    if [ $RESULT -ne 0 ]; then
        exit $RESULT
    fi
else
  echo "Unknown target platform: ${TARGET_PLATFORM}"
  exit 1
fi

##########################################
# setup bluemix env
##########################################
# attempt to  target env automatically
if [ -n "$BLUEMIX_TARGET" ]; then
    # cf not setup yet, try manual setup
    if [ "$BLUEMIX_TARGET" == "staging" ]; then
        echo -e "Targetting staging Bluemix"
        export BLUEMIX_API_HOST="api.stage1.ng.bluemix.net"
    elif [ "$BLUEMIX_TARGET" == "prod" ]; then
        echo -e "Targetting production Bluemix"
        export BLUEMIX_API_HOST="api.ng.bluemix.net"
    else
        echo -e "${red}Unknown Bluemix environment specified: ${BLUEMIX_TARGET}${no_color}" | tee -a "$ERROR_LOG_FILE"
        echo -e "Targetting production Bluemix"
        export BLUEMIX_TARGET="prod"
        export BLUEMIX_API_HOST="api.ng.bluemix.net"
    fi
else

    CF_API=$(${EXT_DIR}/cf api)
    RESULT=$?
    debugme echo "CF_API: ${CF_API}"
    if [ $RESULT -eq 0 ]; then
        # find the bluemix api host
        export BLUEMIX_API_HOST=`echo $CF_API  | awk '{print $3}' | sed '0,/.*\/\//s///'`
        echo $BLUEMIX_API_HOST | grep 'stage1'
        if [ $? -eq 0 ]; then
            # on staging, make sure bm target is set for staging
            export BLUEMIX_TARGET="staging"
        else
            # on prod, make sure bm target is set for prod
            export BLUEMIX_TARGET="prod"
        fi
    else
        echo -e "Targetting production Bluemix"
        export BLUEMIX_TARGET="prod"
        export BLUEMIX_API_HOST="api.ng.bluemix.net"
    fi
fi
echo -e "Bluemix host is '${BLUEMIX_API_HOST}'"
echo -e "Bluemix target is '${BLUEMIX_TARGET}'"
# strip off the hostname to get full domain
CF_TARGET=`echo $BLUEMIX_API_HOST | sed 's/[^\.]*//'`
if [ -z "$API_PREFIX" ]; then
    API_PREFIX=$DEF_API_PREFIX
fi
if [ -z "$REG_PREFIX" ]; then
    REG_PREFIX=$DEF_REG_PREFIX
fi
# build api server hostname
export CCS_API_HOST="${API_PREFIX}${CF_TARGET}"
# build registry server hostname
export CCS_REGISTRY_HOST="${REG_PREFIX}${CF_TARGET}"
# set up the ice cfg
sed -i "s/ccs_host =.*/ccs_host = $CCS_API_HOST/g" $EXT_DIR/ice-cfg.ini
sed -i "s/reg_host =.*/reg_host = $CCS_REGISTRY_HOST/g" $EXT_DIR/ice-cfg.ini
sed -i "s/cf_api_url =.*/cf_api_url = $BLUEMIX_API_HOST/g" $EXT_DIR/ice-cfg.ini
export ICE_CFG="ice-cfg.ini"

############################
# enable logging to logmet #
############################
setup_met_logging "${BLUEMIX_USER}" "${BLUEMIX_PASSWORD}"
RESULT=$?
if [ $RESULT -ne 0 ]; then
    log_and_echo "$WARN" "LOGMET setup failed with return code ${RESULT}"
fi

