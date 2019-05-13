# Role which activates a fullblown instance of GLPI on a node
#
# @summary Role which activates a fullblown instance of GLPI on a node
#
# @example
#   include role::glpi
class role::glpi {
  contain ::profile::glpi_standalone
}
