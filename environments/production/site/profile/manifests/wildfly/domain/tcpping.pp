
/*
  Example:
  $tcpping_configs = [{
    inbound_endpoint => {
      name => 'jgroups-tcpping',
      socket_binding_group => 'full-ha-sockets',
      fixed_port => false,
      interface => 'private',
      port => '7610',
    },
    profile => 'full-ha',
    outbound_destinations => [{
        name: 'jgroups-tcp-slave1'
        socket_binding_group: 'full-ha-sockets'
        host: '127.0.0.1'
        port: '7610'}],
    channels => ['ee']
  }]
*/
class profile::wildfly::domain::tcpping (
  $tcpping_configs = []) {

    require ::profile::wildfly::domain::controller

    $protocol = "TCPPING"
    $stack = downcase($protocol)

    $tcpping_configs.each | $index, $tcpping_config | {
      # notify { "Applying profile profile::wildfly::domain::tcpping for index ${index}": }

      $outbound_destinations = $tcpping_config['outbound_destinations']
      $inbound_endpoint = $tcpping_config['inbound_endpoint']
      $channels = $tcpping_config['channels']
      $profile = $tcpping_config['profile']


      $protocols = {
        $protocol => { 'socket-bindings' => $outbound_destinations },
        'MERGE3' => {},
        'FD_SOCK' => { 'socket-binding' => 'jgroups-tcp-fd' },
        'FD_ALL' => {},
        'VERIFY_SUSPECT' => {},
        'pbcast.NAKACK2' => {},
        'UNICAST3' => {},
        'pbcast.STABLE' => {},
        'pbcast.GMS' => {},
        'MFC' => {},
        'FRAG2' => {},
      }

      

      wildfly::resource { "/profile=${profile}/subsystem=jgroups/stack=${stack}":
        ensure => present,
        recursive => true,
        content   => {
          'protocol'  => $protocols,
          'transport' => {
            'TCP' => {
              'socket-binding' => $inbound_endpoint,
            },
          },
        },
        require => Wildfly::Resource["/socket-binding-group=full-ha-sockets/socket-binding=${inbound_endpoint}"],
      }


      $channels.each | $index, $channel | {
        wildfly::resource { "/profile=${profile}/subsystem=jgroups/channel=${channel}":
          ensure => present,
          content   => {
            stack => $stack,
          },
          require => Wildfly::Resource["/profile=${profile}/subsystem=jgroups/stack=${stack}"],
        }
      }

      
    }

    

}
