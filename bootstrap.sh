#!/bin/bash
# This script assumes that puppet and r10k are already installed
# It will configure r10k and a companion webhook so that i can trigger
# puppet runs after a git push
set -u
R10K=/usr/local/bin/r10k
PUPPET=/opt/puppetlabs/bin/puppet
PUPPET_RUN=/usr/local/bin/puppetrun
FACTS=/etc/puppetlabs/facter/facts.d
MODULE_DIR=/tmp/puppet
REPODIR="$(dirname $0)"
REMOTE=$(cd ${REPODIR};git remote -v | awk 'NR==1 { print $2 }')

mkdir -pv "$MODULE_DIR"

# Setting first git remote as an upstream for profile::r10k
mkdir -pv "$FACTS"
echo "puppet_control_repo=${REMOTE}" > "${FACTS}/bootstrap.txt"

$R10K puppetfile install --moduledir "$MODULE_DIR" --puppetfile ./Puppetfile -v info && \
  $PUPPET apply\
    --hiera_config ${REPODIR}/hiera.yaml\
    --modulepath "${REPODIR}/site:${MODULE_DIR}"\
    -v\
    ${REPODIR}/manifests/bootstrap.pp
rm -rf "$MODULE_DIR"
$R10K deploy environment -p -v info && $PUPPET_RUN

