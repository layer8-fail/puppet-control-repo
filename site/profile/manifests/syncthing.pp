# This thingy throws syncthing on a host, through the magic of docker
class profile::syncthing(
  $manage_firewalld = true,
  $manage_service   = true,
  $service_enable   = true,
  $docker_image     = 'syncthing/syncthing',
  $docker_image_tag = 'v0.14.44',
  $config_dir_path  = '/data/syncthing/config',
  $data_dir_path    = '/data/syncthing/sync',
  $syncthing_ports  = [
    {
      'port'     => '8384',
      'protocol' => 'tcp',
    },
    {
      'port'     => '22000',
      'protocol' => 'tcp',
    },
  ]
) {
  docker::image { $docker_image:
    image_tag => $docker_image_tag,
  }
  if $manage_firewalld {
    $syncthing_ports.each |Hash $item| {
      firewalld_rich_rule { "Allow syncthing access from remote, Port $item['port']/$item['protocol']":
        ensure => present,
        zone   => 'restricted',
        action => 'accept',
        port   => {
          'port'     => $item['port'],
          'protocol' => $item['protocol'],
        },
      }
    }
  }
}
