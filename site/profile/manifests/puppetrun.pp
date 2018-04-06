class profile::puppetrun(
  Stdlib::Absolutepath $path          = '/usr/local/bin/puppetrun',
  String $template                    = "${module_name}/puppetrun.sh.epp",
  String $environment                 = 'production',
  Stdlib::Absolutepath $codedir       = '/etc/puppetlabs/code',
  Stdlib::Absolutepath $puppet_binary = '/opt/puppetlabs/bin/puppet',
  String $manifest                    = 'site.pp',
  String $flags                       = '-v',
) {
  file{ $path:
    ensure  => file,
    content => epp($template,
      {
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
