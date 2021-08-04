class profile::wildfly::host::controller(
  $domain_bind_address, 
  $bind_address, 
  $domain_secret,
  $remote_username, 
  $remote_password,
  $host = $::hostname,
  $server_name = "server-${::hostname}", 
  $server_group = null,
  $properties = undef) {
  
  $props = $properties + {
      'jboss.domain.master.address' => $domain_bind_address,
      'jboss.bind.address'          => $bind_address,
  }

  #$secret = base64('encode', $domain_secret)

  #notify { "The base64 encoded domain secret is ${secret}": } ->

  class { 'profile::wildfly::domain': 
    config     => 'host-slave.xml',
    properties  => $props,
    secret_value => "${domain_secret}",
    #secret_value => 'd2lsZGZseQ==', #base64('wildfly')
    remote_username => $remote_username,
  }

  firewalld_port { 'Open port 8159 in the public zone':
    ensure   => present,
    zone     => 'public',
    port     => 8159,
    protocol => 'tcp',
  }

  wildfly::host::server_config { 'server-one':
    ensure => absent,
  }
  wildfly::host::server_config { 'server-two':
    ensure => absent,
  }

  if $server_name {
    if $server_group {
      wildfly::host::server_config { "${server_name}":
        ensure => present,
        server_group => "${server_group}",
        hostname => "${host}",
        username => "${remote_username}",
        password => "${remote_password}",
        controller_address => $domain_bind_address,
      }
    }
  }

}
