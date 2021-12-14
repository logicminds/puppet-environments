#!/usr/bin/env bash

# Author: NWOPS, LLC
# Date: 12/9/2021
# Purpose: allows code manager to setup yaml environments
# Usage: Place this script /etc/puppetlabs/r10k/r10k-environments.sh
# Add below to your hiera data
# puppet_enterprise::master::code_manager::sources:
#   puppet:
#     remote: 'N/A'
#     type: exec
#     #type: yaml
#     #config: '/etc/puppetlabs/r10k/environments.yaml' 
#     command: '/etc/puppetlabs/r10k/r10k-environments.sh' 

# Note: The pe-puppet user will need to have the key of the git server
# so the known hosts file must contain the entry for the git server.  Either
# add the known_hosts file to /etc/ssh/known_hosts or run the following as the pe-puppet user
# su - pe-puppet -s /bin/bash.  ssh git@gitserver  (accept key when prompted)

# Older versions of git do not support the GIT_SSH_COMMAND environment variable
# especially on OS older than RHEL8.  As a work around you can install pdk which also ships with a 
# new version pdk.  Note you can always install a newer version of git as well.
export PATH=/opt/puppetlabs/pdk/private/git/bin:$PATH

LOG_TIME=$(date -Iseconds)
# Change the below url to the puppet-environments repo where
# r10k-enviornments.yaml lives
GIT_URL="https://github.com/nwops/puppet-environments.git"
# Git must be in the path
GIT_COMMAND=$(which git)
# Required directory so pe-puppet user can write to it
BASE_SERVER_DIR="/opt/puppetlabs/server/data/puppetserver"
# Directory where git will clone the git url to
REPO_DIR="${BASE_SERVER_DIR}/puppet-environments"
# Location where the log file will be created, must be writeable by pe-puppet
LOG_FILE="${BASE_SERVER_DIR}/r10k-yaml.log"
# Environments.yaml file
YAML_FILE="${REPO_DIR}/r10k-environments.yaml"
# path to where the r10k key file is 
# not required with https git urls
SSH_PRIVATE_KEY_FILE="/etc/puppetlabs/puppetserver/ssh/id-control_repo.rsa"
# The command git will use to use ssh url
# not required with https git urls
GIT_SSH_COMMAND="ssh -i ${SSH_PRIVATE_KEY_FILE}"

if [[ ! -f $GIT_COMMAND ]]; then
  echo "\nGit does not appear to be installed or in the PATH\n"
  exit 1
fi
# Append log with new time stamp
echo $LOG_TIME >> $LOG_FILE
if [[ $? -ne 0 ]]; then
  echo "Cannot write to log file destination"
  echo "Run touch $LOG_FILE"
  echo "Then chown pe-puppet:pe-puppet $LOG_FILE"
  exit 1
fi

if [[ -f ${YAML_FILE} ]]; then
  cd ${REPO_DIR}
  ${GIT_COMMAND} pull --ff-only --autostash &>> $LOG_FILE
  if [[ $? -ne 0 ]]; then
    echo "Command failed, using cached value" >> ${LOG_FILE}
    echo "\nSomething happen and the script did not execute correctly\n" >> ${LOG_FILE}
  fi
else
  ${GIT_COMMAND} clone -q $GIT_URL ${REPO_DIR} &>> $LOG_FILE
  if [[ $? -ne 0 ]]; then
    echo "\nSomething happen and the script did not execute correctly\n" >> ${LOG_FILE}
    echo "Check log file ${LOG_FILE}"
    exit 1
  fi
fi


cat ${YAML_FILE} | sed 's|[[:blank:]]*#.*||;/./!d;'
if [[ $(id -u) -eq 0 ]]; then
  # ran as root, if we don't delete our tracks then code manager fails
  echo "Please remove: rm -f ${LOG_FILE}"
  echo "Please remove: rm -rf ${REPO_DIR}"
  echo "Code manager does not work due to permissions"
fi
