# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include profile::bareos_master
class profile::bareos_master (
  Boolean $manage_database     = true,
  Boolean $manage_director     = true,
  Boolean $manage_storage      = true,
  Boolean $manage_client       = true,
  String $client_password      = 'please_change_me',
  String $director_password    = 'please_change_me',
  String $storage_address      = undef,
  String $storage_password     = 'please_change_me',
  String $storage_backing_root = '/var/lib/bareos/storage',
  String $db_name              = 'bareos_catalog',
  String $db_user              = 'bareos',
  String $db_password          = 'OMG please change this',
  String $db_address           = 'localhost',
  String $db_port              = '5432',
){
  if $manage_database {
    include ::postgresql::server
  }
  class { '::bareos': }
  class { '::bareos::profile::director':
    password         => $director_password,
    storage_address  => 'localhost',
    storage_password => $storage_password,
    catalog_conf     => {
      'db_driver'   => 'postgresql',
      'db_name'     => $db_name,
      'db_address'  => $db_address,
      'db_port'     => $db_port,
      'db_user'     => $db_user,
      'db_password' => $db_password,
    },
  }

  # add storage server to the same machine
  class { '::bareos::profile::storage':
    password       => $storage_password,
    archive_device => $storage_backing_root,
  }

  if $manage_client {
    ::bareos::director::client { $facts['networking']['fqdn']:
      description => "BareOS Master Client: ${facts['networking']['fqdn']}",
      password    => $client_password,
      address     => $facts['networking']['fqdn'],
    }
    # Create an backup job by referencing to the jobDef template.
    ::bareos::director::job { "backup_${facts['networking']['fqdn']}":
      job_defs => 'LinuxAll',
      client   => $facts['networking']['fqdn'],
    }
  }

}
