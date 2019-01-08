class hid($role="agent") {

  package {
#   'apt-transport-https':
#     ensure => 'installed';
   'lsb-release':
     ensure => 'installed';
  }

  file { '/usr/bin/python':
    ensure => 'link',
    target => '/usr/bin/python3'
#    onlyif => 'test -e /usr/bin/python'
  }

  apt::source { 'wazuh':
    comment  => 'Used for keeping wazuh (host intrusion detection system) up to date.',
    release  => 'stable',
    repos    => 'main',
    location => 'https://packages.wazuh.com/3.x/apt/',
    key      => {
      id     => '96B3EE5F29111145',
      source => 'https://packages.wazuh.com/key/GPG-KEY-WAZUH'
    },
    include  => {
      source => true,
      deb    => true
    }
  }

  if ($role == 'server') {
    apt::source { 'nodejs':
      comment  => 'Used for keeping nodejs up to date.',
      release  => "${os['distro']['codename']}",
      repos    => 'main',
      location => 'https://deb.nodesource.com/node_11.x',
      key      => {
        id     => '1655A0AB68576280',
        source => 'https://deb.nodesource.com/gpgkey/nodesource.gpg.key'
      },
      include  => {
        source => true,
        deb    => true
      }
    }
    package {
      'wazuh-manager':
        ensure  => 'latest',
        require => [
          Apt::Source['wazuh'],
          Class['apt::update']
        ];
      'nodejs': #for api
        ensure  => 'latest',
        require => [
          Apt::Source['nodejs'],
          Class['apt::update']
        ];
      'wazuh-api':
        ensure  => 'latest',
        require => [
          Apt::Source['wazuh'],
          Class['apt::update']
        ];
    }
  } else {
    package {
      'wazuh-agent':
        ensure  => 'latest',
        require => [
          Apt::Source['wazuh'],
          Class['apt::update']
        ];
    }
  }
}
