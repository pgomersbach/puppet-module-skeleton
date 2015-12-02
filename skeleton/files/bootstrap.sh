#!/usr/bin/env bash
#
# This script installs puppet 3.x or 4.x on ubuntu and centos
#
#set -e

# default major version, comment to install puppet 3.x
PUPPETMAJOR=4

### Code start ###
function provision_ubuntu {
    # get release info
    . /etc/lsb-release
    if [ $PUPPETMAJOR -eq 4 ]; then
      REPO_DEB_URL="http://apt.puppetlabs.com/puppetlabs-release-pc1-${DISTRIB_CODENAME}.deb"
      AGENTNAME="puppet-agent"
    else
      REPO_DEB_URL="http://apt.puppetlabs.com/puppetlabs-release-${DISTRIB_CODENAME}.deb"
      AGENTNAME="puppet"
    fi
    # configure repos
    echo "Configuring PuppetLabs repo..."
    repo_deb_path=$(mktemp)
    wget --output-document="${repo_deb_path}" "${REPO_DEB_URL}" 2>/dev/null
    dpkg -i "${repo_deb_path}" >/dev/null
    apt-get update >/dev/null
    # Install Puppet
    echo "Installing Puppet..."
    apt-get -y  install $AGENTNAME >/dev/null
    echo "Puppet installed!"
}

function provision_rhel() {
    # rpm -ivh https://yum.puppetlabs.com/el/6/products/x86_64/puppetlabs-release-6-7.noarch.rpm
    # yum install -y puppet
}

if [ "$(id -u)" != "0" ]; then
  echo "This script must be run as root." >&2
  exit 1
fi

grep -i "ubuntu" /etc/issue
if [ $? -eq 0 ]; then
    provision_ubuntu
fi

grep -i "red hat" /etc/issue
if [ $? -eq 0 ]; then
    provision_rhel
fi

if [ $PUPPETMAJOR -eq 4 ]; then
    # make symlinks
    echo "Set symlinks"
    FILES=/opt/puppetlabs/bin/*
    for f in $FILES
    do
      filename="${f##*/}"
      ln -f -s $f /usr/local/bin/$filename
    done
fi
