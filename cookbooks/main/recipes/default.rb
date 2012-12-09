execute "apt-get update" do
  command "apt-get update"
end

%w(
  expect-dev
  ruby1.9.1
  ruby1.9.1-dev
  rubygems1.9.1
  irb1.9.1
  ri1.9.1
  rdoc1.9.1
  build-essential
  libopenssl-ruby1.9.1
  libssl-dev
  zlib1g-dev
  lib32gcc1).each do |pkg|
  package pkg
end

%w(rake).each do |gem|
  gem_package gem
end
