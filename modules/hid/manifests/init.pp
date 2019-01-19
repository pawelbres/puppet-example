class hid($role="agent", $network="192.168.41.0", $mask="255.255.255.0") {

  $wuzah_username = "foo"
  $wuzah_password = "bar"

  $hid_interface = $networking['interfaces'].filter |$iter| {
    $interface = $iter[1]
    $mask == $interface['netmask'] and $network == $interface['network']
  }.values()[0]

  package {
#   'apt-transport-https':
#     ensure => 'installed';
   'lsb-release':
     ensure => 'installed';
   'openssl':
     ensure => 'installed';
   'jq':
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
    apt::source { 'elastic':
      comment  => 'Used to install filebeats to forward wuzah server messages to logstash',
      release  => 'stable',
      repos    => 'main',
      location => 'https://artifacts.elastic.co/packages/6.x/apt',
      key      => {
        id     => '46095ACC8548582C1A2699A9D27D666CD88E42B4',
        source => 'https://artifacts.elastic.co/GPG-KEY-elasticsearch'
      }
    }
    package {
      'wazuh-manager':
        ensure  => 'latest',
        require => [
          Package['openssl'],
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
      'filebeat':
        ensure  => 'latest',
        require => [
          Class['apt::update']
        ]
    }
    file {
      '/etc/filebeat/filebeat.yml':
        ensure  => 'present',
        require => Package['filebeat'],
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        source  => 'puppet:///modules/hid/filebeat.yml';
      '/var/ossec/etc/sslmanager.cert':
        ensure  => 'present',
        require => Package['wazuh-manager'],
        owner   => 'root',
        group   => 'root',
        mode    => '0600',
        source  => 'puppet:///modules/hid/sslmanager.cert';
      '/var/ossec/etc/sslmanager.key':
        ensure  => 'present',
        require => Package['wazuh-manager'],
        owner   => 'root',
        group   => 'root',
        mode    => '0600',
        source  => 'puppet:///modules/hid/sslmanager.key';
      '/var/ossec/etc/rootCA.pem':
        ensure  => 'present',
        require => Package['wazuh-manager'],
        owner   => 'root',
        group   => 'root',
        mode    => '0600',
        source  => 'puppet:///modules/hid/rootCA.pem';
    }
    service { 'filebeat':
      ensure    => 'running',
      enable    => 'true',
      subscribe => File['/etc/filebeat/filebeat.yml']
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
    file {
      '/var/ossec/etc/sslagent.cert':
        ensure  => 'present',
        require => Package['wazuh-agent'],
        owner   => 'root',
        group   => 'root',
        mode    => '0600',
        source  => 'puppet:///modules/hid/sslagent.cert';
      '/var/ossec/etc/sslagent.key':
        ensure  => 'present',
        require => Package['wazuh-agent'],
        owner   => 'root',
        group   => 'root',
        mode    => '0600',
        source  => 'puppet:///modules/hid/sslagent.key';
      '/var/ossec/etc/rootCA.pem':
        ensure  => 'present',
        require => Package['wazuh-agent'],
        owner   => 'root',
        group   => 'root',
        mode    => '0600',
        source  => 'puppet:///modules/hid/rootCA.pem';
      '/var/ossec/etc/ossec.conf':
        ensure  => 'present',
        require => Package['wazuh-agent'],
        owner   => 'root',
        group   => 'root',
        mode    => '0600',
        source  => 'puppet:///modules/hid/ossec.conf';
    }
    exec { 'register-agent':
      command => "/usr/bin/curl -S -u ${wuzah_username}:${wuzah_password} -d 'name=${hostname}&ip=${hid_interface['ip']}' 'http://192.168.41.11:55000/agents' | jq -r '.data.key' | base64 -d > /var/ossec/etc/client.keys",
      creates => '/var/ossec/etc/client.keys',
      user    => 'root'
    }
    service { 'wazuh-agent':
      ensure  => 'running',
      enable  => 'true',
      require => [
        File['/var/ossec/etc/sslagent.cert'],
        File['/var/ossec/etc/sslagent.key'],
        File['/var/ossec/etc/rootCA.pem'],
        File['/var/ossec/etc/ossec.conf'],
        Exec['register-agent']
      ]
    }
  }
}
