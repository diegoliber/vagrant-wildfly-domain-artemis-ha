## Wildfly 18.0.1.Final Domain (plus ActiveMQ Cluster with High Availability), provisioned with Vagrant, VirtualBox and Puppet

This project is a fork of [this Vagrant project](https://github.com/jairojunior/wildfly-domain-vagrant-puppet), but adding additional features, such as a more complete profile, the ability of running many slave hosts (I fixed a problem that prevented doing so), custom wildfly profiles, additional server groups and a fully functional ActiveMQ Cluster, with data replication and two live-backup pairs.

## Requirements

Working vagrant and Virtualbox. And Ruby (for r10k) 

Then:

`./setup.sh`

OR

`gem install r10k --no-ri --no-rdoc`

`r10k puppetfile install`

`vagrant up`


## Environment

Multi-machine environment with:

* load-balancer                              (centos-7-httpd-modcluster) (Apache + mod_cluster)
* domain-controller                          (centos-7-domain-controller) (Wildfly 9.0.2 Domain Controller)
* slave1                                     (centos-7-slave) (Wildfly 9.0.2 Host Controller)
* slave2                                     (centos-7-slave) (Wildfly 9.0.2 Host Controller)
* slave3 (artemis backup of slave1)          (centos-7-slave) (Wildfly 9.0.2 Host Controller)
* slave4 (artemis backup of slave2)          (centos-7-slave) (Wildfly 9.0.2 Host Controller)

Check: `environments/production/manifests/site.pp`

Using:

* biemond-wildfly
* puppetlabs-apache
* puppetlabs-java
* crayfishx/firewalld

## Console

http://172.28.128.20:9990

user: wildfly
password: wildfly

## Known bugs

Because of a bug of the biemond-wildfly puppet module, some times it is necessary to provision a slave machine for a second time until puppet run without any errors. This happens because this puppet module uses jboss-cli to configure wildfly, but sometimes wildfly takes too long to start and join the domain-controller, which can timeout executions of jboss-cli command, or perform a command before the state of the wildfly server is updated.

<!-- 
## mod_cluster_manager

http://172.28.128.10:6666/mod_cluster_manager

## hawt.io

http://172.28.128.10/hawtio
-->