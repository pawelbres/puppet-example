node 'edge-node1.example.3lite.eu' {

  notify { 'assignment_message':
    message => 'Configuration of edge-node1.example.3lite.eu will be applied'
  }

  include apt

  include ntp
  include lynis
  include hid
}

