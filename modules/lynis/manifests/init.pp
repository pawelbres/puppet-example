class lynis {

  apt::source { 'lynis':
    comment  => 'Used for keeping lynis (host security scanner) up to date.',
    release  => 'stable',
    repos    => 'main',
    location => 'https://packages.cisofy.com/community/lynis/deb/',
    key      => {
      id      => 'C80E383C3DE9F082E01391A0366C67DE91CA5D5F',
      server  => 'keyserver.ubuntu.com'
    },
    include  => {
      source => true,
      deb    => true
    }
  }

  package { 'apt-transport-https':
    ensure => 'installed'
  }

  package { 'kbtin':
    ensure => 'installed'
  }

  package { 'lynis':
    ensure  => 'latest',
    require => [
      Class['apt::update'],
      Apt::Source['lynis'],
      Package['apt-transport-https']
    ]
  }

  schedule { 'daily-check':
    period => 'daily',
    repeat => 1
  }

  file { "/vagrant/${trusted['hostname']}":
    ensure => 'directory'
  }

  exec { 'run-lynis':
    command  => "/usr/sbin/lynis -c audit system | /usr/bin/ansi2html -la > /vagrant/${trusted['hostname']}/lynis.report.html",
    creates  => "/vagrant/${trusted['hostname']}/lynis.report.html",
    schedule => 'daily-check',
    require  => [
      Package['kbtin'],
      Package['lynis']
    ],
    notify   => Exec['copy-report']
  }
  exec { 'copy-report':
    command     => "/bin/cp /var/log/lynis.* /vagrant/${trusted['hostname']}/",
    refreshonly => true
  }

}
