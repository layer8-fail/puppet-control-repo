class role::base {
  contain ::profile::base
  contain ::profile::mosh
  contain ::profile::users
  contain ::profile::cert_deploy
}
