class ntp {

  package { 'ntp':
    ensure => 'latest'
  }

  service { 'ntp':
    ensure => 'running',
    enable => 'true'
  }

  file { '/etc/ntp.conf':
    ensure => 'present',
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    source => 'puppet:///modules/ntp/ntp.conf'
  }
}
