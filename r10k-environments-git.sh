#!/usr/bin/env bash

export PATH:$PATH:/usr/bin

# This is a sample yaml environment exec command you can use to dynamically generate a environments yaml content
# /etc/puppetlabs/r10k/r10k-environments.sh
if [[ -f /etc/puppetlabs/r10k/puppet-environments/r10k-environments.yaml ]]; then
  cd /etc/puppetlabs/r10k/puppet-environments
  git pull > /dev/null 2>&1
else
  git clone https://github.com/nwops/puppet-environments.git /etc/puppetlabs/r10k/puppet-environments > /dev/null 2>&1
fi
if [[ $? -ne 0 ]]; then
  echo "Something happen and the script did not execute correctly"
  exit 1
fi
cat /etc/puppetlabs/r10k/puppet-environments/r10k-environments.yaml
