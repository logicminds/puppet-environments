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
 
GIT_URL="https://github.com/nwops/puppet-environments.git"
GIT_COMMAND=$(which git)
BASE_SERVER_DIR="/opt/puppetlabs/server/data/puppetserver"
REPO_DIR="${BASE_SERVER_DIR}/puppet-environments"
LOG_FILE="${BASE_SERVER_DIR}/r10k-yaml.log"
YAML_FILE="${REPO_DIR}/r10k-environments.yaml"

if [[ $? -ne 0 ]]; then
  echo "\nGit does not appear to be installed or in the PATH\n"
  exit 1
fi
touch $LOG_FILE
if [[ $? -ne 0 ]]; then
  echo "Cannot write to log file destination"
  echo "Run touch $LOG_FILE"
  echo "Then chown pe-puppet:pe-puppet $LOG_FILE"
  exit 1
fi
# This is a sample yaml environment exec command you can use to dynamically generate a environments yaml content
# /etc/puppetlabs/r10k/r10k-environments.sh
if [[ -f ${YAML_FILE} ]]; then
  cd ${REPO_DIR}
  ${GIT_COMMAND} pull --rebase 2>&1 >> ${LOG_FILE}
else
  ${GIT_COMMAND} clone -q $GIT_URL ${REPO_DIR} 2>&1 >> ${LOG_FILE}
fi
if [[ $? -ne 0 ]]; then
  echo "\nSomething happen and the script did not execute correctly\n"
  echo "Check log file ${LOG_FILE}"
  exit 1
fi

cat ${YAML_FILE} | sed 's|[[:blank:]]*#.*||;/./!d;'
if [[ $(id -u) -eq 0 ]]; then
  # ran as root, if we don't delete our tracks then code manager fails
  echo "Please remove ${LOG_FILE}"
  echo "Please remove ${REPO_DIR}"
  echo "Code manager does not work due to permissions"
fi
