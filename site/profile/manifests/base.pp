class profile::base {
  if $::facts['os']['name'] == 'SuSE' and $::facts['os']['major'] >= 15 {
    contain ::chrony
  }
  else {
    contain ::ntp
  }
  contain ::ssh
  include ::firewalld
  class { 'sudo':
    purge               => false,
    config_file_replace => false,
  }
  include sudo::configs
}
