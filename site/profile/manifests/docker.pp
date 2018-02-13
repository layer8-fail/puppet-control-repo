class profile::docker() {
  class { '::docker': } ->
  class { '::traefik': }
}
