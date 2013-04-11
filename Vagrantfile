Vagrant.configure("2") do |config|
  config.vm.box = "quantal"
  # config.vm.box_url = "http://domain.com/path/to/above.box"

  [10000, 27015, 28015].each do |port|
    # config.vm.network :forwarded_port, guest: port, host: port, protocol: 'tcp'
    config.vm.network :forwarded_port, guest: port, host: port, protocol: 'udp'
  end

  config.vm.network :private_network, ip: "10.10.10.25"

  config.vm.synced_folder "~/tf2", "/opt/shared"

  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--memory", "2048"]
  end

  config.vm.provision :chef_solo do |chef|
    chef.add_recipe "main"
  end
end
