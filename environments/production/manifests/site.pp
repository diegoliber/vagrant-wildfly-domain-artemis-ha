node 'load-balancer' {

  include role::lb

}

node 'domain-controller' {

  include role::appserver::master
  
}

node 'slave1' {
  include role::appserver::slave
}

node 'slave2' {
  include role::appserver::slave
}

node 'slave3' {
  include role::appserver::slave
}

node 'slave4' {
  include role::appserver::slave
}
