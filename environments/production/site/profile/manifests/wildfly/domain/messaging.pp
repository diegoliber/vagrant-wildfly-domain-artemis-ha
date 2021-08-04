class profile::wildfly::domain::messaging (
  $messaging_configs = [{
    queue_configs => [],
    topic_configs => [],
    profile => 'full-ha',
    jgroups_channel => 'activemq-channel',
    jgroups_cluster => 'activemq-cluster',
    connector => ['http-connector'],
    broadcast_group => 'bg-group1',
    broadcast_period => 2000,
    discovery_group => 'dg-group1',
    refresh_timeout => 10000,
    cluster_user => 'artemis',
    cluster_password => 'P@ssword00',
    ha_policy => undef,
    cluster_name => 'msg-cluster',
    group_name => '${messaging.ha.group_name}',
    ha_props => {},
  }],
  
) {

  require ::profile::wildfly::domain::controller

  $messaging_configs.each | $index, $messaging_config | {

    

    $queue_configs = $messaging_config['queue_configs']
    $topic_configs = $messaging_config['topic_configs']
    $mode = $messaging_config['mode']
    $role = $messaging_config['role']
    $cluster_name = $messaging_config['cluster_name']
    $ha_policy = $messaging_config['ha_policy']
    
    if ($messaging_config['ha_props']) {
      $ha_props = $messaging_config['ha_props']
    } else {
      $ha_props = {}
    }

    if ($messaging_config['group_name']) {
      $group_name = $messaging_config['group_name']
    } else {
      $group_name = '${messaging.ha.group_name}'
    }
    

    $queue_configs.each | Integer $index, Hash $queue_config | {

      wildfly::resource { "/profile=${messaging_config['profile']}/subsystem=messaging-activemq/server=default/jms-queue=${queue_config['name']}":
        content => {
          'entries'  => $queue_config['entries'],
          'durable'  => $queue_config['durable'],
          'selector' => $queue_config['selector'],
        }
      }
    }

    $topic_configs.each | Integer $index, Hash $topic_config | {

      wildfly::resource { "/profile=${messaging_config['profile']}/subsystem=messaging-activemq/server=default/jms-topic=${topic_config['name']}":
        content => {
          'entries' => $topic_config['entries'],
        },
      }

    }

    wildfly::resource { "/profile=${messaging_config['profile']}/subsystem=messaging-activemq/server=default":
      ensure => present,
      content => {
        'cluster-user'     => $messaging_config['cluster_user'],
        'cluster-password' => $messaging_config['cluster_password'],
      }
    } ->

    wildfly::resource { "/profile=${messaging_config['profile']}/subsystem=messaging-activemq/server=default/broadcast-group=${messaging_config['broadcast_group']}":
      ensure => present,
      content => {
        'jgroups-channel'  => $messaging_config['jgroups_channel'],
        'jgroups-cluster'  => $messaging_config['jgroups_cluster'],
        'connectors'       => $messaging_config['connectors'],
        'broadcast-period' => $messaging_config['broadcast_period'],
      },
      require => Wildfly::Resource["/profile=${messaging_config['profile']}/subsystem=jgroups/channel=${messaging_config['jgroups_channel']}"]
    } ->

    wildfly::resource { "/profile=${messaging_config['profile']}/subsystem=messaging-activemq/server=default/discovery-group=${messaging_config['discovery_group']}":
      ensure => present,
      content => {
        'jgroups-channel' => $messaging_config['jgroups_channel'],
        'jgroups-cluster' => $messaging_config['jgroups_cluster'],
        'refresh-timeout' => $messaging_config['refresh_timeout'],
      },
      require => Wildfly::Resource["/profile=${messaging_config['profile']}/subsystem=jgroups/channel=${messaging_config['jgroups_channel']}"]
    }

    notify { "Messaging HA policy of profile ${messaging_config['profile']} is ${ha_policy}": }

    if ($ha_policy != undef) {
      $content = $ha_props + {
        'cluster-name' => $cluster_name,
        'group-name'   => $group_name,
      }

      notify { "Properties of Messaging HA policy of profile ${messaging_config['profile']} are ${content}": } ->

      wildfly::resource { "/profile=${messaging_config['profile']}/subsystem=messaging-activemq/server=default/ha-policy=${ha_policy}":
        ensure  => present,
        content => $content,
      }
    }

  }

}
