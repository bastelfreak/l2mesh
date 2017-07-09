# vim: set expandtab:
define l2mesh::host(
  $host,
  $ip,
  $port,
  $tcp_only,
  $public_key,
  $tag_conf,
  $reload,
  $service,
  $file_tag,
  $fqdn = $name,
  $conf = undef,
) {

  file { $host:
    owner   => root,
    group   => root,
    mode    => '0444',
    notify  => Exec[$reload],
    before  => Service[$service],
    tag     => $file_tag,
    content => template('l2mesh/host.erb'),

  }
  concat::fragment { "${tag_conf}_${fqdn}":
    target  => $conf,
    tag     => "${tag_conf}_${fqdn}",
    content => "ConnectTO = ${fqdn}\n",
  }
}
