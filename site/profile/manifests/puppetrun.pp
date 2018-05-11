class profile::puppetrun(
  Stdlib::Absolutepath $path          = '/usr/local/bin/puppetrun',
  String $template                    = "${module_name}/puppetrun.sh.epp",
  Stdlib::Absolutepath $codedir       = '/etc/puppetlabs/code',
  Stdlib::Absolutepath $puppet_binary = '/opt/puppetlabs/bin/puppet',
  String $manifest                    = 'site.pp',
  String $flags                       = '-v',
  Boolean $cronjob                    = true,
  String $cron_minutes                = '*/30',
) {
  file{ $path:
    ensure  => file,
    content => epp($template,
      {
        'puppet'      => $puppet_binary,
        'codedir'     => $codedir,
        'manifest'    => $manifest,
        'flags'       => $flags,
      }
    ),
    mode    => '750',
    owner   => 'root',
    group   => 'root',
  }
  if $cronjob {
    cron{'puppetrun':
      command => $path,
      user    => 'root',
      minute  => $cron_minutes,
    }
  }
}
