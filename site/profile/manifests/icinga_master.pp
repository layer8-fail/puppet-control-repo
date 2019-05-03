# This profile sets up a bare-bone icinga2 master
# and the corresponding database if desired
#
# @summary set up a icinga 2 master
#
# @example
#   include profile::icinga_master
class profile::icinga_master (
  Boolean $manage_database = true,
  Boolean $manage_ca       = true,
  Enum[pgsql] $db_engine   = 'pgsql',
  String $db_host          = 'localhost',
  String $db_user          = 'icinga2',
  String $db_password      = 'icinga2',
  String $db_name          = 'icinga2',
){
  class{'icinga2':
    manage_repo => true,
  }
  if $manage_ca {
    class { '::icinga2::pki::ca': }
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
    pki             => 'puppet',
  }
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
