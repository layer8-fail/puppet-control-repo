class profile::base {
  contain ::ntp
  contain ::ssh
  include ::firewalld
}
