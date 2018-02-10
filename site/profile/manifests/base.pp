class profile::base {
  contain ::ntp
  contain ::ssh
  contain ::firewalld
}
