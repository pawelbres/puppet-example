# -*- mode: ruby -*-
# vi: set ft=ruby :

def setup_network(node_config, servername)
  node_config.vm.provision "shell", inline: <<-SHELL
    if grep -q "puppetmaster" /etc/hosts ; then
      echo "already configured" >> /dev/null
    else
      echo "#{servername}" > /etc/hostname
      hostname $(cat /etc/hostname)
      echo "domain example.3lite.eu" >> /etc/resolvconf/resolv.conf.d/head
      resolvconf -u
      echo -e "192.168.41.10\tpuppetmaster.example.3lite.eu puppetmaster" >> /etc/hosts
      echo -e "192.168.41.11\thost-node1.example.3lite.eu host-node1" >> /etc/hosts
      echo -e "192.168.41.12\tedge-node1.example.3lite.eu edge-node1" >> /etc/hosts
    fi
  SHELL
end

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://vagrantcloud.com/search.
  config.vm.box = "ubuntu/xenial64"

  config.vm.define "puppetmaster" do |puppetmaster|
    puppetmaster.vm.network "private_network", ip: "192.168.41.10"
    setup_network puppetmaster, "puppetmaster"
    puppetmaster.vm.provision "shell", inline: <<-SHELL
      dpkg -i /vagrant/puppet6-release-xenial.deb
      echo "puppetmaster" > /etc/hostname
      apt-get update
      apt-get install -y ntp puppetserver
      echo 'PATH="/opt/puppetlabs/bin:$PATH"' >> ~/.bashrc
      echo "server 0.pl.pool.ntp.org" >> /etc/ntp.conf
      echo "server 1.pl.pool.ntp.org" >> /etc/ntp.conf
      echo "server 2.pl.pool.ntp.org" >> /etc/ntp.conf
      echo "server 3.pl.pool.ntp.org" >> /etc/ntp.conf
      systemctl restart ntp
      if [ ! -f "/vagrant/modules/hid/files/sslagent.cert" ]; then
        cd /vagrant/ && bash create_certificates.sh
      fi
      cp /vagrant/puppet.server.conf /etc/puppetlabs/puppet/puppet.conf
      cp -r /vagrant/modules /etc/puppetlabs/code/environments/production/
      cp -r /vagrant/manifests /etc/puppetlabs/code/environments/production/
      /opt/puppetlabs/bin/puppet module install -v '6.2.1' 'puppetlabs-apt'
      /opt/puppetlabs/bin/puppetserver ca setup --subject-alt-names puppet,ubuntu-xenial,puppetmaster.example.3lite.eu
      sed -i 's/Xms2g/Xms512m/g' /etc/default/puppetserver
      sed -i 's/Xmx2g/Xmx512m/g' /etc/default/puppetserver
      systemctl enable puppetserver
      systemctl start puppetserver
    SHELL
  end

  config.vm.define "host-node1" do |node|
    node.vm.network "private_network", ip: "192.168.41.11"
    setup_network node, "host-node1"
    node.vm.provision "shell", inline: <<-SHELL
      dpkg -i /vagrant/puppet6-release-xenial.deb
      apt-get update
      apt-get install -y puppet-agent
      echo 'PATH="/opt/puppetlabs/bin:$PATH"' >> ~/.bashrc
      cp /vagrant/puppet.agent.conf /etc/puppetlabs/puppet/puppet.conf
      /opt/puppetlabs/bin/puppet resource service puppet ensure=running enable=true
    SHELL
  end

  config.vm.define "edge-node1" do |edge|
    edge.vm.network "private_network", ip: "192.168.41.12"
    setup_network edge, "edge-node1"
    edge.vm.provision "shell", inline: <<-SHELL
      dpkg -i /vagrant/puppet6-release-xenial.deb
      apt-get update
      apt-get install -y puppet-agent
      echo 'PATH="/opt/puppetlabs/bin:$PATH"' >> ~/.bashrc
      cp /vagrant/puppet.agent.conf /etc/puppetlabs/puppet/puppet.conf
      /opt/puppetlabs/bin/puppet resource service puppet ensure=running enable=true
    SHELL
  end
  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # NOTE: This will enable public access to the opened port
  # config.vm.network "forwarded_port", guest: 80, host: 8080

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine and only allow access
  # via 127.0.0.1 to disable public access
  # config.vm.network "forwarded_port", guest: 80, host: 8080, host_ip: "127.0.0.1"

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  # config.vm.network "private_network", ip: "192.168.33.10"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  # config.vm.provider "virtualbox" do |vb|
  #   # Display the VirtualBox GUI when booting the machine
  #   vb.gui = true
  #
  #   # Customize the amount of memory on the VM:
  #   vb.memory = "1024"
  # end
  #
  # View the documentation for the provider you are using for more
  # information on available options.

  # Enable provisioning with a shell script. Additional provisioners such as
  # Puppet, Chef, Ansible, Salt, and Docker are also available. Please see the
  # documentation for more information about their specific syntax and use.
  # config.vm.provision "shell", inline: <<-SHELL
  #   apt-get update
  #   apt-get install -y apache2
  # SHELL
end
