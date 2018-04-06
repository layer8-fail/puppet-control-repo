<%- |
  String $puppet,
  Stdlib::Absolutepath $codedir,
  String $environment = 'production',
  String $manifest = 'site.pp',
  String $flags = '-v'
| -%>
#!/bin/bash
<%= $puppet %> apply <%= $flags %> <%= $codedir %>/<%= $environment %>/manifests<%= $manifest%>
