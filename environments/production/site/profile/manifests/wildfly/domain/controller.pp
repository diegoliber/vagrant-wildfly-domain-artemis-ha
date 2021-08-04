class profile::wildfly::domain::controller(
  $properties, 
  $proxies,
  $server_groups = [],
  $loggers = [],
  $profiles = [{
    name => 'sample',
    source => 'full-ha'
  }],
  $inbound_endpoints = [],
  $outbound_destinations = []) {

  class { 'profile::wildfly::domain':
    config     => 'host-master.xml',
    properties => $properties,
  }

  # notify { "Profiles: ${profiles}": }

  $profiles.each | $index, $profile | {
    wildfly::cli { "Created profile ${profile['name']} from ${profile['source']}":
      command => "/profile=${profile['source']}:clone(to-profile=${profile['name']})",
      unless  => "(outcome == success) of /profile=${profile['name']}:read-resource",
      #require => Notify["Profiles: ${profiles}"]
    }
  }

  wildfly::domain::server_group{ 'main-server-group':
    ensure => absent,
  
  }

  wildfly::domain::server_group{ 'other-server-group':
    ensure => absent,
  
  }

  $inbound_endpoints.each | $index, $inbound_endpoint | {
    wildfly::resource { "/socket-binding-group=${inbound_endpoint['socket_binding_group']}/socket-binding=${inbound_endpoint['name']}":
      ensure => present,
      content => {
        'fixed-port' => false, 
        'interface' => $inbound_endpoint['interface'],
        'port' => $inbound_endpoint['port'],
      },
      # notify => Wildfly::Resource["/profile=${profile}/subsystem=jgroups/stack=${stack}"],
    }
  }

  $outbound_destinations.each | $index, $destination | {
    wildfly::resource { "/socket-binding-group=${destination['socket_binding_group']}/remote-destination-outbound-socket-binding=${destination['name']}":
      ensure => present,
      content => {
        'host' => $destination['host'],
        'port' => $destination['port'],
      },
      # notify => Wildfly::Resource["/profile=${profile}/subsystem=jgroups/stack=${stack}"],
    }
  }

  if $server_groups {
    $server_groups.each |$index, $server_group| {  
      wildfly::domain::server_group{ $server_group['name']:
        ensure => present,
        profile => $server_group['profile'],
        socket_binding_group => $server_group['socket_binding_group'],
        socket_binding_port_offset => $server_group['socket_binding_port_offset'],    
      }
    }
  }

  # wildfly::deployment { 'hawtio.war':
  #   source       => 'https://repo1.maven.org/maven2/io/hawt/hawtio-web/1.4.68/hawtio-web-1.4.68.war',
  #   server_group => 'other-server-group',
  # }

  $proxies.each |$index, $proxy| {
    $host_port = split($proxy, ':')

    wildfly::resource { "/socket-binding-group=full-ha-sockets/remote-destination-outbound-socket-binding=proxy${index}":
      content => {
        'host' => $host_port[0],
        'port' => $host_port[1],
      },
      before  => Wildfly::Modcluster::Config['mycluster']
    }
  }

  $number_of_proxies = count($proxies) - 1

  wildfly::modcluster::config { 'mycluster':
    balancer             => 'mycluster',
    load_balancing_group => 'demolb',
    proxy_url            => '/',
    proxies              => range('proxy0',"proxy${number_of_proxies}"),
    target_profile       => 'full-ha',
  }

  $loggers.each | $index, $logger | {
    wildfly::resource { "/profile=${logger['profile']}/subsystem=logging/logger=${logger['name']}":
      ensure => present,
      content => {
        category => $logger['name'],
        level => $logger['level'],
      }
    }
  }
}
