#!/usr/bin/env bash

# This is a sample yaml environment exec command you can use to dynamically generate a environments yaml content
# /etc/puppetlabs/r10k/r10k-environments.sh

# Even though we specify no cache the server may still have the content loaded.  Until the cache is busted the content
# returned will not be changed.
curl -s -H 'Cache-Control: no-cache' https://raw.githubusercontent.com/logicminds/puppet-environments/main/environments.yaml
