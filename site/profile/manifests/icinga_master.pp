# This profile sets up a bare-bone icinga2 master
# and the corresponding database if desired
#
# @summary set up a icinga 2 master
#
# @example
#   include profile::icinga_master
class profile::icinga_master (
  Boolean $manage_database   = true,
  Boolean $manage_ca         = false,
  String $api_ticket_salt    = undef,
  Enum[pgsql] $db_engine     = 'pgsql',
  String $db_host            = 'localhost',
  String $db_user            = 'icinga2',
  String $db_password        = 'icinga2',
  String $db_name            = 'icinga2',
  Array $additional_packages = [],
  Hash $api_users            = {},
  Hash $api_user_defaults    = {},
){
  ensure_packages($additional_packages)

  class{'icinga2':
    manage_repo => true,
  }
  if $manage_ca {
    class { '::icinga2::pki::ca': }
    $api_tls_config = {
      'pki'         => 'icinga2',
      'ticket_salt' => $api_ticket_salt,
    }
  }
  else {
    $api_tls_config = {
      'pki' => 'puppet'
    }
  }
  class{ '::icinga2::feature::idopgsql':
    user          => $db_user,
    password      => $db_password,
    database      => $db_name,
    import_schema => true,
  }

  class { '::icinga2::feature::api':
    accept_commands => true,
    accept_config   => true,
    *               => $api_tls_config,
  }

  ensure_resource('::icinga2::object::apiuser', $api_users, $api_user_defaults)

  if $manage_database {
    if $db_engine == 'pgsql' {
      include ::postgresql::server
      postgresql::server::db { $db_name:
        user     => $db_user,
        password => postgresql_password($db_user, $db_password),
      }
      Postgresql::Server::Db[$db_name] -> Class['::icinga2::feature::idopgsql']
    }
  }
}
