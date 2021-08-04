class profile::wildfly::domain(
  $config, 
  $properties, 
  $mgmt_user,
  $app_users = [], 
  $remote_username = undef, 
  $install_cache_dir = '/var/cache/wget', 
  $secret_value = undef) {

  include java

  file { "$install_cache_dir": 
    ensure => directory,
    mode => '0755'
  }

  class { 'wildfly':
    java_home    => '/etc/alternatives/java_sdk',
    mode         => 'domain',
    host_config  => $config,
    properties   => $properties,
    secret_value => $secret_value,
    install_cache_dir => $install_cache_dir,
    mgmt_user => $mgmt_user,
    version => '18.0.1',
    remote_username => $remote_username,
  }

  $app_users.each | $index, $app_user | {
    wildfly::config::app_user { $app_user['name']:
      password => $app_user['password'],
    }

    wildfly::config::user_roles { $app_user['name']:
      roles => $app_user['roles'],
    }
  }
  
  Class['java'] ->
  File["$install_cache_dir"] ->
    Class['wildfly']

}
