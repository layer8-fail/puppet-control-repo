# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include profile::glpi_standalone
class profile::glpi_standalone (
  Boolean $manage_firewall = true,
){
  contain nginx
  contain glpi
  contain mysql::server

  if $manage_firewall {
    ['http','https'].each |$svc| {
      firewalld_service {"Allow access to $svc":
        ensure  => present,
        service => $svc,
        zone    => 'public',
      }
    }
  }
}
