require 'rake/testtask'

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

  exec %Q{
    rm -rf #{server_path}
    mkdir -p #{server_path}
    cp test/fixtures/ok.json #{server_path}/settings.json
    cd #{server_path}
    BUILD_DIR=#{$bootstrap_shared} #{$build_dir}/bin/run settings.json
  }
end

task :compile do
  system %Q{
    rm -rf #{$build_dir}
    mkdir -p #{$build_dir} #{$cache_dir}
    bin/compile #{$build_dir} #{$cache_dir}
  }
end

task :publish => :compile do
  system %Q{
    cd #{$build_dir}
    archive-dir http://party-cloud-production.s3.amazonaws.com/funpacks/slugs/team-fortress-2/stable.tar.lzo *
  }
end