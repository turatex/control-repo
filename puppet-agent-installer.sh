#!/bin/bash

set -e
set -u
set -o pipefail

PUPPET_AGENT_VERSION=$1

detect_rhel_7 ( ) {

  if egrep ' 7\.' /etc/redhat-release &> /dev/null; then
    yum install -y https://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm
    yum install -y "puppet-agent-${PUPPET_AGENT_VERSION}"
  fi

}

detect_rhel_6 ( ) {

  if egrep ' 6\.' /etc/redhat-release &> /dev/null; then
    yum install -y https://yum.puppetlabs.com/puppetlabs-release-pc1-el-6.noarch.rpm
    yum install -y "puppet-agent-${PUPPET_AGENT_VERSION}"
  fi

}

detect_rhel_5 ( ) {

  if egrep ' 5\.' /etc/redhat-release &> /dev/null; then
    echo 'nameserver 8.8.8.8' > /etc/resolv.conf
    cd /tmp
    curl -O http://yum.puppetlabs.com/RPM-GPG-KEY-puppet
    rpm --import RPM-GPG-KEY-puppet
    curl -O http://yum.puppetlabs.com/puppetlabs-release-pc1-el-5.noarch.rpm
    yum install -y puppetlabs-release-pc1-el-5.noarch.rpm
    yum install -y "puppet-agent-${PUPPET_AGENT_VERSION}"
  fi

}

detect_ubuntu_1604 ( ) {

  if egrep 'DISTRIB_RELEASE=16.04' /etc/lsb-release &> /dev/null; then
    cd /tmp
    curl -O http://apt.puppetlabs.com/puppetlabs-release-pc1-xenial.deb
    dpkg -i puppetlabs-release-pc1-xenial.deb
    apt-get update
    apt-get install "puppet-agent=${PUPPET_AGENT_VERSION}*"
  fi

}

detect_ubuntu_1404 ( ) {

  if egrep 'DISTRIB_RELEASE=14.04' /etc/lsb-release &> /dev/null; then
    cd /tmp
    curl -O http://apt.puppetlabs.com/puppetlabs-release-pc1-trusty.deb
    dpkg -i puppetlabs-release-pc1-trusty.deb
    rm puppetlabs-release-pc1-trusty.deb
    apt-get update
    # Confirm because the box already comes with a puppet package installed
    apt-get install -y "puppet-agent=${PUPPET_AGENT_VERSION}*"
    apt-get autoremove -y # The box comes with lots of not needed stuff
  fi

}

detect_ubuntu_1204 ( ) {

  if egrep 'DISTRIB_RELEASE=12.04' /etc/lsb-release &> /dev/null; then
    cd /tmp
    curl -O http://apt.puppetlabs.com/puppetlabs-release-pc1-precise.deb
    dpkg -i puppetlabs-release-pc1-precise.deb
    rm puppetlabs-release-pc1-precise.deb
    apt-get update
    # Confirm because the box already comes with a puppet package installed
    apt-get install -y "puppet-agent=${PUPPET_AGENT_VERSION}*"
    apt-get autoremove -y # The box comes with lots of not needed stuff
  fi

}

detect_debian_6 ( ) {

  if egrep '^6\.[0-9]' /etc/debian_version &> /dev/null; then
    cd /tmp
    wget http://apt.puppetlabs.com/puppetlabs-release-pc1-squeeze.deb
    dpkg -i puppetlabs-release-pc1-squeeze.deb
    rm puppetlabs-release-pc1-squeeze.deb
    apt-get update
    apt-get install "puppet-agent=${PUPPET_AGENT_VERSION}*"
  fi

}

detect_debian_7 ( ) {

  if egrep '^7\.[0-9]' /etc/debian_version &> /dev/null; then
    cd /tmp
    wget http://apt.puppetlabs.com/puppetlabs-release-pc1-wheezy.deb
    dpkg -i puppetlabs-release-pc1-wheezy.deb
    rm puppetlabs-release-pc1-wheezy.deb
    apt-get update
    apt-get install "puppet-agent=${PUPPET_AGENT_VERSION}*"
  fi

}

detect_debian_8 ( ) {

  if egrep '^8\.[0-9]' /etc/debian_version &> /dev/null; then
    cd /tmp
    wget http://apt.puppetlabs.com/puppetlabs-release-pc1-jessie.deb
    dpkg -i puppetlabs-release-pc1-jessie.deb
    rm puppetlabs-release-pc1-jessie.deb
    apt-get update
    apt-get install "puppet-agent=${PUPPET_AGENT_VERSION}*"
  fi

}

detect_debian_9 ( ) {

  if egrep '^9\.[0-9]' /etc/debian_version &> /dev/null; then
    cd /tmp
    wget http://apt.puppetlabs.com/puppetlabs-release-pc1-stretch.deb
    dpkg -i puppetlabs-release-pc1-stretch.deb
    rm puppetlabs-release-pc1-stretch.deb
    apt-get update
    apt-get install "puppet-agent=${PUPPET_AGENT_VERSION}*"
  fi

}

detect_sles_12 ( ) {

  if egrep 'VERSION_ID="12' /etc/os-release &> /dev/null; then
    # Puppet repositories are already configured
    # Do not enable GPG check on Puppet repositories. It will break unattended install
    zypper refresh puppetlabs-pc1
    zypper install --oldpackage --no-recommends --no-confirm "puppet-agent=${PUPPET_AGENT_VERSION}"
  fi

}

detect_sles_11 ( ) {

  if egrep 'VERSION_ID="11' /etc/os-release &> /dev/null; then
    # Remove old Puppet gems
    gem uninstall --all --executables facter hiera puppet
    zypper install --no-confirm http://yum.puppetlabs.com/puppetlabs-release-pc1-sles-11.noarch.rpm
    # Disable GPG check on Puppet repositories or it will break unattended install
    zypper modifyrepo -G puppetlabs-pc1
    zypper install --oldpackage --no-recommends --no-confirm "puppet-agent=${PUPPET_AGENT_VERSION}"
  fi

}

detect_rhel_5
detect_rhel_6
detect_rhel_7
detect_ubuntu_1604
detect_ubuntu_1404
detect_ubuntu_1204
detect_debian_6
detect_debian_7
detect_debian_8
detect_debian_9
detect_sles_11
detect_sles_12
