# This thingy throws syncthing on a host, through the magic of docker
class profile::syncthing(
  $manage_firewalld = true,
  $manage_service   = true,
  $systemd_unit_path = '/etc/systemd/system/syncthing.service',
  $docker_image     = 'syncthing/syncthing',
  $docker_image_tag = 'v0.14.51',
  $config_dir_path  = '/data/syncthing/config',
  $data_dir_path    = '/data/syncthing/sync',
  $syncthing_ports  = [
    {
      'port'     => '22000',
      'protocol' => 'tcp',
    },
  ]
) {
  docker::image { $docker_image:
    image_tag => $docker_image_tag,
    notify    => Service['syncthing']
  }
  if $manage_firewalld {
    $syncthing_ports.each |Hash $item| {
      firewalld_port { "Allow syncthing access from remote, Port ${item['port']}/${item['protocol']}":
        ensure   => present,
        zone     => 'public',
        port     => "${item['port']}",
        protocol => "${item['protocol']}",
      }
    }
  }
  if $manage_service {
    include ::systemd::systemctl::daemon_reload

    file { $systemd_unit_path:
      ensure  => file,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => epp('profile/syncthing.service.epp'),
    } ~> Class['systemd::systemctl::daemon_reload']
    service {'syncthing':
      ensure    => 'running',
      subscribe => File[$systemd_unit_path],
    }
  }
}
