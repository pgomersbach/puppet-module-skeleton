#!/usr/bin/env bash
#
# This bootstraps role_aio on Ubuntu 14.04 LTS and deploy this module
# Usage:
# wget https://github.com/pgomersbach/test-role_aio/raw/master/files/bootsrap.sh
# bash bootstrap.sh
#
set -e

# Load up the release information
. /etc/lsb-release

REPO_DEB_URL="http://apt.puppetlabs.com/puppetlabs-release-pc1-trusty.deb"

echo $REPO_DEB_URL
echo $DISTRIB_CODENAME
