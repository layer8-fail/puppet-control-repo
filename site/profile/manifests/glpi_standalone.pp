# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include profile::glpi_standalone
class profile::glpi_standalone (
  Boolean $manage_firewall = true,
  Boolean $manage_repos    = true,
  String $upstream_url     = 'glpi.lab.fail',
  Integer $port            = 80,
  String $php_fpm_url      = 'localhost:8000',
){
  if ! $facts['os']['family'] == 'RedHat' {
    fail('Only works on RHEL/CentOS for now')
  }

  contain ::nginx
  class{'::glpi':
    manage_repos => $manage_repos,
  }
  if $facts['os']['release']['major'] == 7 and $manage_repos {
    ensure_packages('rh-mariadb102-runtime')
  }
  contain ::mysql::server

  nginx::resource::server { $upstream_url:
    listen_port => $port,
    proxy       => $php_fpm_url,
  }

  if $manage_firewall {
    ['http','https'].each |$svc| {
      firewalld_service {"Allow access to $svc":
        ensure  => present,
        service => $svc,
        zone    => 'public',
      }
    }
  }
}
