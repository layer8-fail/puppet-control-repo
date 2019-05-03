# Setup the icingaweb2 Web-UI
#
# @summary setup icingaweb2
#
# @example
#   include profile::icingaweb2
class profile::icingaweb2 (
  Boolean $manage_database          = true,
  Boolean $manage_webserver         = true,
  Boolean $manage_firewall          = true,
  Boolean $manage_repos             = true,
  String $firewall_zone             = 'public',
  Boolean $manage_module_monitoring = true,
  String $ido_db_host               = 'localhost',
  String $ido_db_user               = 'icinga2',
  String $ido_db_password           = 'icinga2',
  Integer[1,65535] $ido_db_port     = 5432,
  String $ido_db_name               = 'icinga2',
  Enum[pgsql] $db_engine            = 'pgsql',
  String $db_host                   = 'localhost',
  String $db_user                   = 'icingaweb2',
  String $db_password               = 'icingaweb2',
  Integer[1,65535] $db_port         = 5432,
  String $db_name                   = 'icingaweb2',
  Stdlib::Absolutepath $app_base    = '/usr/share/icingaweb2/public/',
  String $server_name               = 'monitor.lab.fail',
  Enum[nginx] $webserver            = 'nginx',
  String $webserver_user            = 'nginx',
  Boolean $use_tls                  = false,
  Optional[String] $tls_public_key  = undef,
  Optional[String] $tls_private_key = undef,
  String $tls_path                  = '/etc/nginx/certs',
  String $tls_file_owner            = 'nginx',
  String $tls_file_group            = 'nginx'
){
  if $manage_repos {
    if $facts['os']['family'] == 'RedHat' {
      include epel
      include scl
      ::scl::collection{'rh-php71':
        before => Class['::icingaweb2'],
      }
    }
    else {
      fail('Only RHEL-derivatives are supported')
    }
  }
  class {'::icingaweb2':
    import_schema => true,
    db_type       => $db_engine,
    db_host       => $db_host,
    db_port       => $db_port,
    db_username   => $db_user,
    db_password   => $db_password,
    conf_user     => $webserver_user,
  }

  if $manage_module_monitoring {
    class {'::icingaweb2::module::monitoring':
      ido_host          => $ido_db_host,
      ido_port          => $ido_db_port,
      ido_db_name       => $ido_db_name,
      ido_db_username   => $ido_db_password,
      ido_db_password   => $ido_db_password,
      commandtransports => {
        icinga2 => {
          transport => 'api',
          username  => 'root',
          password  => 'icinga',
        }
      }
    }
  }
  if $manage_firewall {
    ['http','https'].each |$svc| {
      firewalld_service {"Allow access to ${svc}":
        ensure  => present,
        service => $svc,
        zone    => $firewall_zone,
      }
    }
  }
  if $manage_database {
    if $db_engine == 'pgsql' {
      include ::postgresql::server
      postgresql::server::db { $db_name:
        user     => $db_user,
        password => postgresql_password($db_user, $db_password),
      }
      Postgresql::Server::Db[$db_name] -> Class['::icingaweb2::module::monitoring']
    }
  }
  if $manage_webserver {
    if $webserver == 'nginx' {
      if $use_tls {
        if not $tls_public_key or not $tls_private_key {
           fail('You need to configure public/private tls key if you want tls.')
        }
        file { $tls_path:
          ensure => directory,
          owner  => $tls_file_owner,
          group  => $tls_file_group,
        }
        $crt = "${tls_path}/${server_name}.crt"
        $key = "${tls_path}/${server_name}.key"
        file { $crt:
          ensure  => file,
          owner   => $tls_file_owner,
          group   => $tls_file_group,
          content => $tls_public_key,
        }
        file { $key:
          ensure  => file,
          owner   => $tls_file_owner,
          group   => $tls_file_group,
          content => $tls_private_key,
        }
        $nginx_server_tls_conf = {
          'ssl'          => true,
          'ssl_cert'     => $cert,
          'ssl_key'      => $key,
          'ssl_redirect' => true,
        }
        $nginx_location_tls_conf = {
          'ssl'      => true,
          'ssl_only' => true,
        }
      }
      else {
        $nginx_server_tls_conf = {
          'ssl' =>  false
        }
        $nginx_location_tls_conf = {
          'ssl' =>  false
        }
      }
      include ::nginx
      nginx::resource::server { 'icingaweb2':
        server_name          => [$server_name],
        index_files          => [],
        use_default_location => false,
        *                    => $nginx_server_tls_conf,
      }

      nginx::resource::location { 'root':
        location            => '/',
        server              => 'icingaweb2',
        index_files         => [],
        location_cfg_append => {
          rewrite => '^/(.*) https://$host/icingaweb2/$1 permanent'
        }
      }

      nginx::resource::location { 'icingaweb2_index':
        location       => '~ ^/icingaweb2/index\.php(.*)$',
        server         => 'icingaweb2',
        index_files    => [],
        fastcgi        => '127.0.0.1:9000',
        fastcgi_index  => 'index.php',
        fastcgi_script => "${app_base}/index.php",
        fastcgi_param  => {
          'ICINGAWEB_CONFIGDIR' => '/etc/icingaweb2',
          'REMOTE_USER'         => '$remote_user',
        },
        *              => $nginx_location_tls_conf,
      }

      nginx::resource::location { 'icingaweb':
        location       => '~ ^/icingaweb2(.+)?',
        location_alias => $app_base,
        try_files      => ['$1', '$uri', '$uri/', '/icingaweb2/index.php$is_args$args'],
        index_files    => ['index.php'],
        server         => 'icingaweb2',
        *              => $nginx_location_tls_conf,
      }
    }
  }
}
