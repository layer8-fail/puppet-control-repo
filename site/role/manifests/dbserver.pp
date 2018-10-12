# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include role::dbserver
class role::dbserver(
  $type = 'mariadb'
) {
  contain "profile::${type}"
}
