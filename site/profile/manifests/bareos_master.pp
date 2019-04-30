# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include profile::bareos_master
class profile::bareos_master (
  Boolean $manage_database          = true,
  Boolean $manage_director          = true,
  Boolean $manage_storage           = true,
  Boolean $manage_client            = true,
  Boolean $manage_jobdefs           = true,
  Optional[Hash] $jobdefs_defaults  = {},
  Boolean $manage_filesets          = true,
  Optional[Hash] $fileset_defaults  = {},
  String $client_password           = 'please_change_me',
  String $director_password         = 'please_change_me',
  Optional[String] $storage_address = undef,
  String $storage_password          = 'please_change_me',
  String $storage_backing_root      = '/var/lib/bareos/storage',
  String $postgres_user             = 'postgres',
  String $db_name                   = 'bareos_catalog',
  String $db_user                   = 'bareos',
  String $db_password               = 'OMG please change this',
  String $db_address                = 'localhost',
  String $db_port                   = '5432',
){
  if $manage_database {
    include ::postgresql::server
    postgresql::server::db { $db_name:
      user     => $db_user,
      password => postgresql_password($db_user, $db_password),
      notify   => Exec['bareos director init catalog'],
    }
  }
  if $manage_storage {
    $real_storage_address = 'localhost'
  }
  else {
    $real_storage_address = $storage_address
  }

  class { '::bareos':
    manage_database => false,
  }
  class { '::bareos::profile::director':
    password         => $director_password,
    storage_address  => $real_storage_address,
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
  if $manage_database {
    exec { 'bareos director init catalog':
      command     => '/usr/lib/bareos/scripts/make_bareos_tables && /usr/lib/bareos/scripts/grant_bareos_privileges',
      subscribe   => Class['::bareos::profile::director'],
      notify      => Service[$::bareos::director::service_name],
      environment => [
        'dbdriver=postgresql',
        "dbname=${db_name}",
        "dbuser=${db_user}",
        "dbpassword=${db_password}",
      ],
      user        => $postgres_user,
      refreshonly => true,
    }
  }
  if $manage_storage {
    class { '::bareos::profile::storage':
      password       => $storage_password,
      archive_device => $storage_backing_root,
    }
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

  if $manage_jobdefs {
    $my_jobdefs = lookup({'name' => 'bareos_jobdefs',
    'merge' => {
      'strategy'        => 'deep',
      'knockout_prefix' => '--',
    },
    'default_value'   => {},
    })
    ensure_resources('::bareos::director::jobdefs', $my_jobdefs, $jobdefs_defaults)
  }
  if $manage_filesets {
    $my_filesets = lookup({'name' => 'bareos_filesets',
    'merge' => {
      'strategy'        => 'deep',
      'knockout_prefix' => '--',
    },
    'default_value'   => {},
    })
    ensure_resources('::bareos::director::fileset', $my_filesets, $fileset_defaults)
  }
}
