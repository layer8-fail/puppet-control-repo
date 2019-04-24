# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include profile::glpi_standalone
class profile::glpi_standalone {
  contain nginx
  contain glpi
  contain mysql
}
