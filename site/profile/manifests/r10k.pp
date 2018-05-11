class profile::r10k(
  $repo     = $::facts['puppet_control_repo'],
  $cachedir = '/var/cache/r10k',
) {
  file{ $cachedir:
    ensure => directory,
  }
  class{ 'r10k':
    remote                  => $repo,
    provider                => 'puppet_gem',
    cachedir                => $cachedir,
    include_postrun_command => true, # run r10k after a puppet run
  }
}
