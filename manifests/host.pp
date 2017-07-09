# vim: set expandtab:
define l2mesh::host(
  $host,
  $ip,
  $port,
  $tcp_only,
  $tag_conf,
  $service,
  $file_tag,
  $public_key_content = undef,
  $public_key_source  = undef,
  $fqdn               = $name,
  $conf               = undef,
) {

  if $public_key_content and $public_key_source {
    fail("you can't provide public_key_content and public_key_source")
  }
  concat { $host:
    owner   => 'root',
    group   => 'root',
    mode    => '0444',
    notify  => Service[$service],
    before  => Service[$service],
    tag     => $file_tag,
  }

  concat::fragment{"${name}-host":
    target  => $host,
    content => template('l2mesh/host.erb'),
    order   => '01',
  }

  concat::fragment{"${name}-pubkey":
    target  => $host,
    content => $public_key_content,
    source  => $public_key_source,
    order   => '02',
  }

  concat::fragment { "${tag_conf}_${fqdn}":
    target  => $conf,
    tag     => "${tag_conf}_${fqdn}",
    content => "ConnectTO = ${fqdn}\n",
  }
}
