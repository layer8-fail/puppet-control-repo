class profile::base {
  if $::facts['os']['name'] == 'SuSE' and versioncmp($::facts['os']['release']['major'],'15') >= 0 {
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
