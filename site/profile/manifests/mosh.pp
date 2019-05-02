# This class install mosh and opens the firewall on the given ports
#
# @summary Setup mosh, the mobile shell
#
# @example
#   include profile::mosh
class profile::mosh (
  Boolean $manage_firewall     = true,
  String $package              = 'mosh',
  Array $fw_ports              = ['60000','60001'],
  String $fw_zone              = 'public',
  Optional[String] $fw_service = undef,
){
  if $manage_firewall {
    if $fw_ports {
      $fw_ports.each |$svc| {
        firewalld_port {"Allow access to port ${svc}":
          ensure   => present,
          port     => $svc,
          protocol => 'udp',
          zone     => $fw_zone,
        }
      }
    }
    if $fw_service {
      firewalld_service {"Allow access to service ${fw_service}":
        ensure  => present,
        service => $fw_service,
      }
    }
  }
}
