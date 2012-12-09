require 'rake/testtask'

task :default => :test

Rake::TestTask.new do |t|
  t.libs.push "lib"
  t.test_files = FileList['test/*_test.rb']
  t.verbose = true
end

task :compile do
  build_dir = "/opt/funpacks/team-fortress-2/build"
  cache_dir = "/opt/funpacks/team-fortress-2/cache"
  system "mkdir -p #{build_dir}"
  system "bin/compile #{build_dir} #{cache_dir}"
  # system "cp -R /vagrant/bin ~/build"
end

task :start do
  sid = "1234"
  build_dir = "/opt/funpacks/team-fortress-2/build"
  server_path = "tmp/servers/#{sid}"

  system %Q{
    rm -rf #{server_path}
    mkdir -p #{server_path}
    cp test/fixtures/ok.json #{server_path}/settings.json
    cd #{server_path}
    BUILD_DIR=#{build_dir} ../../../bin/run settings.json
  }

end