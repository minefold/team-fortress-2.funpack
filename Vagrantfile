Vagrant::Config.run do |config|
  config.vm.box = "base"

  config.vm.network :hostonly, "10.10.10.15"
  config.vm.customize ["modifyvm", :id, "--memory", 2048]

  [27015, 28015].each do |port|
    config.vm.forward_port port, port
    config.vm.forward_port port, port, protocol: 'udp'
  end

  config.vm.provision :chef_solo do |chef|
    chef.add_recipe "main"
  end
end
