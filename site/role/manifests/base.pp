class role::base {
  contain ::profile::base
  contain ::profile::users
  #contain ::profile::puppetrun
}
