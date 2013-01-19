require 'rake/testtask'

task :default => :test

$build_dir = File.expand_path("~/tf2/build")
$cache_dir = File.expand_path("~/tf2/cache")

Rake::TestTask.new do |t|
  t.libs.push "lib"
  t.test_files = FileList['test/*_test.rb']
  t.verbose = true
end

task :bootstrap do
  system "mkdir -p #{$build_dir}"
  system "bin/bootstrap #{$build_dir} #{$cache_dir}"
  # system "cp -R /vagrant/bin ~/build"
end

task :start do
  sid = "1234"
  server_path = "tmp/servers/#{sid}"

  exec %Q{
    rm -rf #{server_path}
    mkdir -p #{server_path}
    cp test/fixtures/ok.json #{server_path}/settings.json
    cd #{server_path}
    BUILD_DIR=#{$build_dir} ../../../bin/run settings.json
  }
end

task :publish do
  paths = %w(bin lib templates Gemfile Gemfile.lock)
  system %Q{
    archive-dir http://party-cloud-production.s3.amazonaws.com/funpacks/slugs/team-fortress-2/stable.tar.lzo #{paths.join(' ')}
  }
end