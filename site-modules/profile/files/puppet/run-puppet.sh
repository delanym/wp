#!/bin/bash
cd /etc/puppetlabs/code/environments/production && git fetch && git reset --hard @{upstream}
/opt/puppetlabs/puppet/bin/r10k puppetfile install
/opt/puppetlabs/bin/puppet apply --environment production manifests/
