# subnet.pp
define dhcp::subnet (
  $network,
  $mask,
  $gateway         = undef,
  $static_routes   = undef,
  $domain_name     = undef,
  $search_domains  = undef,
  $pxeserver       = undef,
) {

# begin of subnet section
  concat::fragment { "dhcp.conf+70_${name}_1.dhcp":
    target  => "${::dhcp::dhcp_dir}/dhcpd.conf",
    content => template('dhcp/dhcpd.subnet.erb'),
    order   => "70-${name}-1",
  }

# end of subnet section
  concat::fragment{ "dhcp.conf+70_${name}_3.dhcp":
    target  => "${::dhcp::dhcp_dir}/dhcpd.conf",
    content => "}\n\n",
    order   => "70-${name}-3",
  }
}

# middle of subnet section (pools)
define dhcp::subnet::pool (
  $subnet,
  $range,
  $failover        = undef,
  $options         = undef,
  $parameters      = undef,
) {
  concat::fragment { "dhcp.conf+70_${subnet}_2_${name}.dhcp":
    target  => "${::dhcp::dhcp_dir}/dhcpd.conf",
    content => template('dhcp/dhcpd.pool.erb'),
    order   => "70-${subnet}-2-${name}",
  }
}
