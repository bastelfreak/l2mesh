# vim: set expandtab:
define l2mesh::host(
  String $host,
  String $ip,
  Integer $port,
  $tcp_only,
  $tag_conf,
  $service,
  $file_tag,
  String $network,
  String $prefix,
  Integer $prefixlength = 16,
  String $fqdn          = $title,
  $conf                 = undef,
) {

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

  $public_key_content = get_public_keys($facts['fqdn'])
  @@concat::fragment{"${fqdn}-pubkey":
    target  => $host,
    content => $public_key_content,
    order   => '02',
    tag     => $file_tag,
  }
  concat::fragment{"${conf}pubkey":
    #target  => $public,
    target   => "/etc/tinc/${network}/rsa_key.pub",
    content  => $public_key_content,
  }
  # export, collected in main class
  @@concat::fragment { "${tag_conf}_${fqdn}":
    target         => $conf,
    tag            => $file_tag,
    content        => "ConnectTO = ${fqdn}",
  }

  # get the files for all nodes with pub keys
  Concat <<| tag == $file_tag |>>
  Concat::Fragment <<| tag == $file_tag |>>

  # write systemd config
  systemd::network{"${network}.netdev":
    content         => epp("${module_name}/systemd.netdev.epp",
      {
        network => $network
      }),
    restart_service => true,
  }
  if $facts['networking']['interfaces'][$network] {
    $mac = $facts['networking']['interfaces']['elknetwork']['mac']
    $address = $mac
    systemd::network{"${network}.network":
      content         => epp("${module_name}/systemd.network.epp",
        {
          network      => $network,
          prefix       => $prefix,
          address      => $address,
          prefixlength => $prefixlength,
          mac          => $mac
        }),
      restart_service => true,
    }
  }
}
