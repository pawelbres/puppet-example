node 'host-node1.example.3lite.eu' {

  notify { 'assignment_message':
    message => 'Configuration of host-node1.example.3lite.eu will be applied'
  }

  include apt
  include ntp
  include lynis
  class { 'hid':
    role => 'server'
  }
}

