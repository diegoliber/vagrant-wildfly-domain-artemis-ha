class role::appserver::master {
  include profile::wildfly::domain::controller
  include profile::wildfly::domain::tcpping
  include profile::wildfly::domain::messaging
  include profile::wildfly::firewalld

  #Class["profile::wildfly::domain::controller"] ->
  #Class["profile::wildfly::domain::tcpping"] ->
  #Class["profile::wildfly::domain::messaging"] ->
  #Class["profile::wildfly::firewalld"]

}
