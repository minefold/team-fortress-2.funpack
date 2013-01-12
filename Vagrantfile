Vagrant::Config.run do |config|
  config.vm.box = "base"

  config.vm.network :hostonly, "10.10.10.25"
  config.vm.customize ["modifyvm", :id, "--memory", 2048]
  
  # config.vm.boot_mode = :gui

  [10000, 27015, 28015].each do |port|
    config.vm.forward_port port, port
    config.vm.forward_port port, port, protocol: 'udp'
  end

  # Packman
  config.vm.share_folder "packman", "/opt/packman", "../packman"
  config.vm.forward_port 4000, 4000

  config.vm.provision :chef_solo do |chef|
    chef.add_recipe "main"
  end
end
