class profile::docker(
  $manage_firewalld = true,
  $docker_ports  = [
    {
      'port'     => '80',
      'protocol' => 'tcp',
    },
    {
      'port'     => '443',
      'protocol' => 'tcp',
    },
  ]
) {
  class { '::docker': } ->
  class { '::traefik': }

  if $manage_firewalld {
    $docker_ports.each |Hash $item| {
      firewalld_port { "Docker: Allow access from remote, Port ${item['port']}/${item['protocol']}":
        ensure   => present,
        zone     => 'public',
        port     => "${item['port']}",
        protocol => "${item['protocol']}",
      }
    }
  }
}
