#!/usr/bin/env bash

GIT_URL="https://github.com/nwops/puppet-environments.git"
GIT_COMMAND=$(which git)
LOG_FILE='/tmp/r10k-yaml.log'
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
if [[ -f /etc/puppetlabs/r10k/puppet-environments/r10k-environments.yaml ]]; then
  cd /etc/puppetlabs/r10k/puppet-environments
  ${GIT_COMMAND} pull --rebase 2>&1 >> ${LOG_FILE}
else
  ${GIT_COMMAND} clone -q $GIT_URL /etc/puppetlabs/r10k/puppet-environments 2>&1 >> ${LOG_FILE}
fi
if [[ $? -ne 0 ]]; then
  echo "\nSomething happen and the script did not execute correctly\n"
  echo "Check log file ${LOG_FILE}"
  exit 1
fi
cat /etc/puppetlabs/r10k/puppet-environments/r10k-environments.yaml | sed 's|[[:blank:]]*#.*||;/./!d;'
