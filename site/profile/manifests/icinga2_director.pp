# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include profile::icinga2_director
class profile::icinga2_director (
  Boolean $manage_database  = true,
  String $db_host           = 'localhost',
  Enum[pgsql] $db_engine    = 'pgsql',
  String $db_user           = 'icinga2_director',
  String $db_password       = 'icinga2_director',
  Integer[1,65535] $db_port = 5432,
  String $db_name           = 'icinga2_director',
  String $git_revision      = 'v1.6.2',
  String $endpoint          = $facts['networking']['fqdn'],
  String $api_user          = 'director',
  String $api_password      = $::profile::icinga_master::api_users['director']['password']
){
  if $manage_database {
    if $db_engine == 'pgsql' {
      include ::postgresql::server
      postgresql::server::db { $db_name:
        user     => $db_user,
        password => postgresql_password($db_user, $db_password),
      }
      Postgresql::Server::Db[$db_name] -> Class['::icingaweb2::module::director']
    }
  }
  class {'icingaweb2::module::director':
    git_revision  => $git_revision,
    db_type       => $db_engine,
    db_host       => $db_host,
    db_port       => $db_port,
    db_name       => $db_name,
    db_username   => $db_user,
    db_password   => $db_password,
    import_schema => true,
    kickstart     => true,
    endpoint      => $endpoint,
    api_username  => $api_user,
    api_password  => $api_password,
    require       => Package['git'],
  }
}
