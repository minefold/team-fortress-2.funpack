$:.unshift File.expand_path('../lib', __FILE__)

require 'rake/testtask'
require 'bash'
require 'json'

include Bash

task :default => :test

$bootstrap_shared = File.expand_path("~/tf2/shared")
$build_dir = File.expand_path("~/tf2/pack/build")
$cache_dir = File.expand_path("~/tf2/pack/cache")

Rake::TestTask.new do |t|
  t.libs.push "lib"
  t.test_files = FileList['test/*_test.rb']
  t.verbose = true
end

task :bootstrap do
  system "mkdir -p #{$bootstrap_shared}"
  system "bin/bootstrap #{$bootstrap_shared}"
end

task :start do
  sid = "1234"
  server_path = "~/servers/#{sid}"
  settings_file = File.expand_path('../test/fixtures/ok.json', __FILE__)

  exec %Q{
    rm -rf #{server_path}
    mkdir -p #{server_path}
    cp #{settings_file} #{server_path}/settings.json
    cd #{server_path}
    PORT=10000 NAME="My Rad TF2 Server" BUILD_DIR=#{$bootstrap_shared} BUNDLE_GEMFILE=#{$build_dir}/Gemfile #{$build_dir}/bin/run settings.json
  }
end

task :compile do
  fail unless system "build/compile #{$build_dir} #{$cache_dir}"
end

task :publish => :compile do
  require 'tempfile'
  f = Tempfile.new('schema')
  schema = JSON.load(File.read('funpack.json'))['schema']
  f.write(JSON.dump({
      data: {
          id: "50bec3967aae5797c0000004",
          object: {
              schema: schema
          }
      },
      type: "funpack.updated"
  }))
  f.close

  fail unless system "build/publish #{$build_dir} team-fortress-2 #{f.path}"
  #
  # bash <<-EOS
  #   curl --data '#{JSON.dump(update)}' -X POST minefold.com/webhooks/party_cloud
  # EOS
  #   cd #{$build_dir}
  #   archive-dir http://party-cloud-production.s3.amazonaws.com/funpacks/slugs/team-fortress-2/stable.tar.lzo *
  # EOS
end