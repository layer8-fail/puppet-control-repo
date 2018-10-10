class profile::base {
  contain ::ntp
  contain ::ssh
  include ::firewalld
  class { 'sudo':
    purge               => false,
    config_file_replace => false,
  }
  include sudo::configs
}
