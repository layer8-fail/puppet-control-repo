# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include profile::mariadb
class profile::mariadb(
  $mariadb_version = '10.3',
  $mariadb_package_version = "10.3_10.3.10+maria~${::lsbdistcodename}",
  $repo_keyid = '199369E5404BD5FC7D2FE43BCBCB082A1BB943DB',
  $mirror = "http://ftp.osuosl.org/pub/mariadb/repo/${mariadb_version}/ubuntu"
) {
  if $::facts['os']['name'] != 'Ubuntu' {
    fail("${module_name} is currently only supported on Ubuntu")
  }
  include apt

  apt::source { 'mariadb':
    location => $mirror,
    release  => $::lsbdistcodename,
    repos    => 'main',
    key      => {
      id     => $repo_keyid,
      server => 'hkp://keyserver.ubuntu.com:80',
    },
    include  => {
      src => false,
      deb => true,
    },
  }
  class {'::mysql::server':
    package_name     => 'mariadb-server',
    package_ensure   => $mariadb_package_version,
    service_name     => 'mysql',
    override_options => {
      mysqld => {
        'log-error' => '/var/log/mysql/mariadb.log',
        'pid-file'  => '/var/run/mysqld/mysqld.pid',
      },
      mysqld_safe => {
        'log-error' => '/var/log/mysql/mariadb.log',
      },
    }
  }
  # Take care of order
  Apt::Source['mariadb'] ~>
  Class['apt::update'] ->
  Class['::mysql::server']
}
