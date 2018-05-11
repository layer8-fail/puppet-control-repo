class profile::compose_apps (
  Boolean $manage_vcs_repo = true,
  String $vcs_repo         = 'https://github.com/layer8-fail/docker-stuff.git',
  String $dir              = '/opt/docker-stuff',
  String $compose_dir      = 'compose',
  String $vcs_branch       = 'master',
  Array $apps = [],
) {
  vcsrepo { $dir:
  ensure   => latest,
  provider => git,
  source   => $vcs_repo,
  revision => $vcs_branch,
  }

  $apps.each |String $app| {
    docker_compose{ "${dir}/${compose_dir}/${app}/docker-compose.yaml":
      ensure    => present,
      subscribe => Vcsrepo[$dir],
    }
  }
}
