# Install a lightweight desktop and x2go components. Needs EPEL on EL to work
#
# @summary Install a lightweight desktop and x2go components
#
# @example
#   include profile::remote_desktop
class profile::remote_desktop(
  $package_list,
  $desktop_package_group = 'Xfce',
) {
  if $::facts['os']['family'] != 'RedHat' {
    fail("ATM only RedHat family is supported, not ${::facts['os']['family']}")
  }
  yum::group { $desktop_package_group:
    ensure  => present,
    timeout => 600,
  }
  package { 'x2goserver-xsession':
    ensure => present,
  }
  # Make sure to fix permissions, otherwise the sudo parser check will fail
  file { '/etc/sudoers.d/x2goserver':
    mode   => '0440',
  }
  ensure_packages($package_list)
}
