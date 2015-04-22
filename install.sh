#!/bin/bash
set -e
# Load up the release information
. /etc/lsb-release

# Install puppetlabs repo
REPO_DEB_URL="http://apt.puppetlabs.com/puppetlabs-release-${DISTRIB_CODENAME}.deb"
repo_deb_path=$(mktemp)
wget --output-document="${repo_deb_path}" "${REPO_DEB_URL}"
sudo dpkg -i "${repo_deb_path}"

# Update repo's
sudo apt-get update

# Install packages
sudo apt-get -y install git bundler puppet libxslt-dev libxml2-dev

# Install docker
sudo wget -qO- https://get.docker.com/ | sh
sudo usermod -aG docker $USER
exec sg docker newgrp `id -gn`

# Clone skeleton repo
git clone https://github.com/pgomersbach/puppet-module-skeleton

# Install skeleton
cd puppet-module-skeleton
find skeleton -type f | git checkout-index --stdin --force --prefix="$HOME/.puppet/var/puppet-module/" --
cd -
echo "To use this skeleton:"
echo "puppet module generate user-module"
echo "cd user-module"
echo "bundle install"
echo "bundle exec rake"
