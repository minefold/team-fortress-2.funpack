Vagrant::Config.run do |config|
  config.vm.box = "base"

  [27015, 28000].each do |port|
    config.vm.forward_port port, port
    config.vm.forward_port port, port, protocol: 'udp'
  end

  config.vm.share_folder "funpack", "~/team-fortress-2.funpack", "."
  config.vm.share_folder "build", "~/build", "build"
end
