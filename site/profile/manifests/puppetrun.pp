class profile::puppetrun(
  $path          = '/usr/local/bin/puppetrun',
  $template      = "${module_name}/puppetrun.sh.pp",
  $environment   = 'production',
  $codedir       = '/etc/puppetlabs/code',
  $puppet_binary = '/opt/puppetlabs/bin/puppet',
  $manifest      = 'site.pp',
  $flags         = '-v',
) {
  file{$path:
    ensure  => file,
    content => epp($template, {
        'puppet'      => $puppet_binary,
        'codedir'     => $codedir,
        'environment' => $environment,
        'manifests'   => $manifest,
        'flags'       => $flags,
      }
    ),
    mode    => '750',
    owner   => 'root',
    group   => 'root',
  }
}
