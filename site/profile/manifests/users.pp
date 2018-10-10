# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include profile::users
class profile::users {
  $user_list = lookup( { 'name'  => 'local_users',
                  'merge' => {
                    'strategy'        => 'deep',
                    'knockout_prefix' => '--',
                  },
               })
  $user_list.each |String $user, Hash $config| {
    accounts::user { $user:
      * => $config,
    }
  }
}
