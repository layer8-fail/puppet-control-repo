# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include profile::cert_deploy
class profile::cert_deploy (
  Array $certificates = ['lab_fail.pem'],
  String $cert_path   = 'puppet:///modules/profile/certificates/',
){
  class {'::certificate_distribution':
    certificate_list => $certificates,
    source           => $cert_path,
  }
}
