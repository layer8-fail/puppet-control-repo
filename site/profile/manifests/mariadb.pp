# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include profile::mariadb
class profile::mariadb(
  $mariadb_version             = '10.3',
  $mariadb_package_name        = "mariadb-server-${mariadb_version}",
  $mariadb_package_ensure      = 'present',
  $repo_keyid                  = '177F4010FE56CA3336300305F1656F24C74CD1D8',
  $repo_architecture           = 'amd64',
  $mirror                      = "http://ftp.osuosl.org/pub/mariadb/repo/${mariadb_version}/ubuntu",
  $manage_client               = true,
  $mariadb_client_package_name = 'mariadb-client'
) {
  if $::facts['os']['name'] != 'Ubuntu' {
    fail("${module_name} is currently only supported on Ubuntu")
  }
  include apt

  apt::source { 'mariadb':
    location     => $mirror,
    release      => $::lsbdistcodename,
    repos        => 'main',
    key          => {
      id     => $repo_keyid,
      server => 'hkp://keyserver.ubuntu.com:80',
    },
    include      => {
      src => false,
      deb => true,
    },
    architecture => $repo_architecture,
  }
  class {'::mysql::server':
    package_name     => $mariadb_package_name,
    package_ensure   => $mariadb_package_ensure,
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

  if $manage_client {
    class {'::mysql::client':
      package_name    => $mariadb_client_package_name,
      bindings_enable => true,
    }
  }
  # Take care of order
  Apt::Source['mariadb'] ~>
  Class['apt::update'] ->
  Class['::mysql::server']
}
