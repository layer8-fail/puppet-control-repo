class role::everything() {
  class { '::role::base': } ->
  class { '::profile::docker': } ->
  class { '::profile::syncthing': }
}
