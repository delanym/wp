#!/bin/bash
set -eu
PUPPET_REPO=$1
HOSTNAME=$2
BRANCH=$3
if [ "$#" -ne 3 ]; then
  echo "Usage: $0 PUPPET_REPO HOSTNAME BRANCH"
  exit 1
fi
hostname ${HOSTNAME}
echo ${HOSTNAME} >/etc/hostname
source /etc/lsb-release
apt-key adv --fetch-keys http://apt.puppetlabs.com/DEB-GPG-KEY-puppet
wget http://apt.puppetlabs.com/puppet7-release-${DISTRIB_CODENAME}.deb -O puppet7-release-${DISTRIB_CODENAME}.deb
sudo debconf-set-selections <<< 'debconf debconf/frontend select Noninteractive'
dpkg -i puppet7-release-${DISTRIB_CODENAME}.deb
apt-get update
apt-get -y install git puppet-agent
cd /etc/puppetlabs/code/environments
rm -rf --interactive=never production
git config --global --add safe.directory /etc/puppetlabs/code/environments/production
git config --global pull.ff only
git clone ${PUPPET_REPO} production
cd production
git checkout ${BRANCH}
/opt/puppetlabs/puppet/bin/gem install r10k --no-document
/opt/puppetlabs/puppet/bin/r10k puppetfile install --verbose
/opt/puppetlabs/bin/puppet apply --environment=production /etc/puppetlabs/code/environments/production/manifests/
