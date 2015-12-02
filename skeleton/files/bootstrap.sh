#!/usr/bin/env bash
#
# This script installs puppet 3.x or 4.x on ubuntu and centos
#
# Usage:
# Ubuntu / Debian: wget https://raw.githubusercontent.com/pgomersbach/puppet-module-skeleton/master/skeleton/files/bootstrap.sh; bash bootstrap.sh
#
# Red Hat / CentOS: curl https://raw.githubusercontent.com/pgomersbach/puppet-module-skeleton/master/skeleton/files/bootstrap.sh -o bootstrap.sh; bash bootstrap.sh
# Options: add 3 as parameter to install 4.x release

# default major version, comment to install puppet 3.x
PUPPETMAJORVERSION=4

### Code start ###
function provision_ubuntu {
    # get release info
    if [ -f /etc/lsb-release ]; then
      . /etc/lsb-release
    else
      DISTRIB_CODENAME=$(lsb_release -c -s)
    fi
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
    apt-get -y install git $AGENTNAME >/dev/null
    echo "Puppet installed!"
}

function provision_rhel() {
    # get release info
    grep -i "7" /etc/redhat-release
    if [ $? -eq 0 ]; then
      RHMAJOR=7
    fi
    grep -i "6" /etc/redhat-release
    if [ $? -eq 0 ]; then
      RHMAJOR=6
    fi
    if [ $PUPPETMAJOR -eq 4 ]; then
      REPO_RPM_URL="http://yum.puppetlabs.com/puppetlabs-release-pc1-el-${RHMAJOR}.noarch.rpm"
      AGENTNAME="puppet-agent"
    else
      REPO_RPM_URL="http://yum.puppetlabs.com/puppetlabs-release-el-${RHMAJOR}.noarch.rpm"
      AGENTNAME="puppet"
    fi
    yum install -y wget git > /dev/null
    # configure repos
    echo "Configuring PuppetLabs repo..."
    repo_rpm_path=$(mktemp)
    wget --output-document="${repo_rpm_path}" "${REPO_RPM_URL}" 2>/dev/null
    rpm -i "${repo_rpm_path}" >/dev/null
    # install puppet
    echo "Installing Puppet..."
    yum install -y $AGENTNAME >/dev/null
}

if [ "$(id -u)" != "0" ]; then
  echo "This script must be run as root." >&2
  exit 1
fi

if [ "$#" -gt 0 ]; then
   if [ "$1" = 3 ]; then
     PUPPETMAJOR=3
   else
     PUPPETMAJOR=4
  fi
else
  PUPPETMAJOR=$PUPPETMAJORVERSION
fi
echo $PUPPETMAJOR

grep -i "ubuntu" /etc/issue
if [ $? -eq 0 ]; then
    provision_ubuntu
fi
grep -i "Debian" /etc/issue
if [ $? -eq 0 ]; then
    provision_ubuntu
fi

if [ -f /etc/redhat-release ]; then
  grep -i "Red Hat" /etc/redhat-release
  if [ $? -eq 0 ]; then
      provision_rhel
  fi
  grep -i "CentOS" /etc/redhat-release
  if [ $? -eq 0 ]; then
      provision_rhel
  fi
fi

if [ $PUPPETMAJOR -eq 4 ]; then
    # make symlinks
    echo "Set symlinks"
    FILES="/opt/puppetlabs/bin/*"
    for f in $FILES
    do
      filename="${f##*/}"
      ln -f -s "$f" "/usr/local/bin/${filename}"
    done
fi
