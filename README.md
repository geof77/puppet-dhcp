# DHCP module for Puppet

DHCP module for theforeman. Based on original DHCP module by ZLeslie, thanks
to him for the original work.

Installs and manages a DHCP server.

## Dependencies

* Native-type Concat module (https://github.com/onyxpoint/pupmod-concat)

## Features
* Multiple subnet support
* Multiple pools per subnet support
* Class-based filtering for subnet pools
* Host reservations
* Secure dynamic DNS updates when combined with Bind
* Failover support

## Usage
Define the server and the zones it will be responsible for.

    class { 'dhcp':
      dnsdomain    => [
        'dc1.example.net',
        '1.0.10.in-addr.arpa',
        ],
      nameservers  => ['10.0.1.20'],
      interfaces   => ['eth0'],
      dnsupdatekey => "/etc/bind/keys.d/$ddnskeyname",
      require      => Bind::Key[ $ddnskeyname ],
      pxeserver    => '10.0.1.50',
      pxefilename  => 'pxelinux.0',
    }

### dhcp::subnet
Define the subnet attributes

    dhcp::subnet{ 'ops.dc1.example.net':
      network => '10.0.1.0',
      mask    => '255.255.255.0',
      gateway => '10.0.1.1',
    }

Override global attributes with subnet specific attributes

    dhcp::subnet{ 'ops.dc1.example.net':
      network     => '10.0.1.0',
      mask        => '255.255.255.0',
      gateway     => '10.0.1.1',
      nameservers => ['10.0.1.2', '10.0.2.2'],
      pxeserver   => '10.0.1.2',
    }

For the support of static routes (RFC3442):

    dhcp::subnet{ 'ops.dc1.example.net':
      network => '10.0.1.0',
      mask    => '255.255.255.0',
      gateway => '10.0.1.1',
      static_routes =>  [ { 'mask' => '32', 'network' => '169.254.169.254', 'gateway' => $ip } ],
    }

### dhcp::subnet::pool
Define the pools attributes inside a subnet

Simple pool example

    dhcp::subnet::pool { "mypool":
       subnet      => "ops.dc1.example.net"
       range       => "10.0.1.50 10.0.1.250",
       failover    => "dhcp-failover",
    }


Multiple pools with class filtering (see below)

    dhcp::subnet::pool { "ppc64 pool":
       subnet      => "ops.dc1.example.net",
       range       => "10.0.1.10 10.0.1.49",
       failover    => "dhcp-failover",
       pxefilename => "yaboot",
       allow_class => "ppc64",
       parameters  => [
         'deny unknown-clients',
       ],
    }
    dhcp::subnet::pool { "x86_64 pool":
       subnet      => "ops.dc1.example.net",
       range       => "10.0.1.50 10.0.1.250",
       failover    => "dhcp-failover",
       deny_class  => "ppc64",
       parameters  => [
         'allow unknown-clients',
       ],
    }

### dhcp::class
Class filtering

Simple filter on the hostname's first 3 characters

    dhcp::dhcp_class { "ppc64":
      parameters => 'match if substring(option host-name,0,3) = "ppc"'
    }

### dhcp::host
Create host reservations.

    dhcp::host {
      'server1': mac => "00:50:56:00:00:01", ip => "10.0.1.51";
      'server2': mac => "00:50:56:00:00:02", ip => "10.0.1.52";
      'server3': mac => "00:50:56:00:00:03", ip => "10.0.1.53";
      'ppcsrv1': mac => "6c:ae:8b:00:00:10", ip => "10.0.1.11";
      'ppcsrv2': mac => "6c:ae:8b:00:00:20", ip => "10.0.1.11";
    }

## Contributors
Zach Leslie <zach.leslie@gmail.com>
Ben Hughes <git@mumble.org.uk>
Greg Sutcliffe <greg.sutcliffe@gmail.com>
