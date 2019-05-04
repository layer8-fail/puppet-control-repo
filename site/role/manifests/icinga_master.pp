# Set up a complete icinga all-in-one box
#
# @summary Set up icinga/icingaweb with modules
#
# @example
#   include role::icinga_master
class role::icinga_master {
  contain ::profile::icinga_master
  contain ::profile::icingaweb2
  contain ::profile::icinga2_director
}
