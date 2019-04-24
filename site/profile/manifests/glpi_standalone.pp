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
  String $php_fpm_url      = 'localhost:9000',
  String $www_root = '/var/www/glpi/current',
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
    www_root    => $www_root,
  }
  nginx::resource::location { 'glpi_root':
    ensure          => present,
    server          => $upstream_url,
    www_root        => $www_root,
    location        => '~ \.php$',
    index_files     => ['index.php'],
    proxy           => undef,
    fastcgi         => $php_fpm_url,
    fastcgi_script  => undef,
    location_cfg_append => {
      fastcgi_connect_timeout => '3m',
      fastcgi_read_timeout    => '3m',
      fastcgi_send_timeout    => '3m'
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
