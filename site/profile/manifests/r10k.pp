class profile::r10k(
  $repo     = $::facts['puppet_control_repo'],
  $cachedir = '/var/cache/r10k',
) {
  file{$cachedir:
    ensure => directory,
  }
  class{'r10k'
    remote                  => $repo,
    provider                => 'puppet_gem',
    cachedir                => $cachedir,
    include_postrun_command => true, # run r10k after a puppet run
  } ->
  class { 'r10k::webhook::config':
    use_mcollective  => false,
    public_key_path  => '/etc/mcollective/server_public.pem',  # Mandatory even when use_mcollective is false
    private_key_path => '/etc/mcollective/server_private.pem', # Mandatory even when use_mcollective is false
  }
  class { 'r10k::webhook':
    user    => 'root',
    group   => 'root',
  }
}
