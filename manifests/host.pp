# vim: set expandtab:
define l2mesh::host(
  String $host,
  String $ip,
  Integer $port,
  $tcp_only,
  $tag_conf,
  $service,
  $file_tag,
  $public_key_source,
  #$public_key_content = undef,
  String $fqdn,
  String $network,
  $conf               = undef,
) {

  #if $public_key_content and $public_key_source {
  #  fail("you can't provide public_key_content and public_key_source")
  #}
  @@concat { $host:
    owner   => 'root',
    group   => 'root',
    mode    => '0444',
    notify  => Service[$service],
    before  => Service[$service],
    tag     => $file_tag,
  }

  @@concat::fragment{"${fqdn}-host":
    target  => $host,
    content => template('l2mesh/host.erb'),
    order   => '01',
    tag     => $file_tag,
  }

  @@concat::fragment{"${fqdn}-pubkey":
    target  => $host,
    #content => $public_key_content,
    source  => $public_key_source,
    order   => '02',
    tag     => $file_tag,
  }

  # export, collected in main class
  @@concat::fragment { "${tag_conf}_${fqdn}":
    target         => $conf,
    tag            => $file_tag,
    content        => "ConnectTO = ${fqdn}",
    ensure_newline => true,
  }

  # get the files for all nodes with pub keys
  Concat <<| tag == $file_tag |>>
  Concat::Fragment <<| tag == $file_tag |>>

  # write systemd config
  $prefix = 'fd00::'
  $prefixlength = 16
  systemd::network{"${network}.netdev":
    source          => "puppet:///modules/${module_name}/systemd.netdev",
    restart_service => true,
  }
  if $facts['networking']['interfaces'][$network] {
    $mac = $facts['networking']['interfaces']['elknetwork']['mac']
    $address = $mac
    systemd::network{"${network}.network":
      source          => "puppet:///modules/${module_name}/systemd.network",
      restart_service => true,
    }
  }
}
