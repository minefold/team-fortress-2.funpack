$:.unshift File.expand_path('../lib', __FILE__)

require 'rake/testtask'
require 'bash'
require 'json'

include Bash

task :default => :test

$shared_dir = File.expand_path("/opt/shared/shared")
$build_dir = File.expand_path("/opt/shared/build")
$cache_dir = File.expand_path("/opt/shared/cache")
$working_dir = File.expand_path("/opt/shared/working")

Rake::TestTask.new do |t|
  t.libs.push "lib"
  t.test_files = FileList['test/*_test.rb']
  t.verbose = true
end

task :bootstrap do
  system "mkdir -p #{$shared_dir}"
  system "bin/bootstrap #{$shared_dir}"
end

task :start do
  system %Q{
    mkdir -p #{$working_dir}
  }

  gemfile = File.expand_path("#{$build_dir}/Gemfile")
  run = File.expand_path("#{$build_dir}/bin/run")
  Dir.chdir($working_dir) do
    File.write "data.json", <<-EOS
      {
        "settings": {
          "name": "super rad",
          "settings": {
            "max-players": 24,
            "map": "cp_orange_x3",
            "rcon_password": "sup"
          }
        }
      }
    EOS

    raise "error" unless system "PORT=4032 RAM=1024 BUNDLE_GEMFILE=#{gemfile} DATAFILE=#{$working_dir}/data.json SHARED_DIR=#{$shared_dir} #{run} 2>&1"
  end
end


task :compile do
  fail unless system "rm -rf #{$build_dir} && mkdir -p #{$build_dir} #{$cache_dir}"
  fail unless system "bin/compile #{$build_dir} #{$cache_dir} 2>&1"
  Dir.chdir($build_dir) do
    if !system("bundle check")
      fail unless system "bundle install --deployment --without development:test 2>&1"
    end
  end
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
end