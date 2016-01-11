#!/bin/bash
set -e
# Load up the release information
. /etc/lsb-release

# Install puppetlabs repo
REPO_DEB_URL="https://apt.puppetlabs.com/puppetlabs-release-stable.deb"
repo_deb_path=$(mktemp)
wget --output-document="${repo_deb_path}" "${REPO_DEB_URL}"
sudo dpkg -i "${repo_deb_path}"

# Install ruby ppa
sudo apt-get install -y software-properties-common
sudo apt-add-repository -y ppa:brightbox/ruby-ng

# Update repo's
sudo apt-get update

# Install packages
sudo apt-get -y install ruby2.1 ruby2.1-dev git bundler puppet libxslt-dev libxml2-dev zlib1g-dev

# Clone skeleton repo
git clone https://github.com/pgomersbach/puppet-module-skeleton

# Install skeleton
cd puppet-module-skeleton
find skeleton -type f | git checkout-index --stdin --force --prefix="$HOME/.puppet/var/puppet-module/" --
cd -

