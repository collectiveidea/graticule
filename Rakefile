require 'rubygems'
require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'rake/gempackagetask'
require 'rake/contrib/rubyforgepublisher'


PKG_VERSION = "0.1.0"
PKG_NAME = "geocode"
PKG_FILE_NAME = "#{PKG_NAME}-#{PKG_VERSION}"

PKG_FILES = FileList[
    "lib/**/*", "examples/**/*", "[A-Z]*", "rakefile"
].exclude(/\.svn$/)


desc "Default Task"
task :default => [ :test ]

# Run the unit tests

Rake::TestTask.new(:test) do |t|
  t.pattern = 'test/unit/**/*_test.rb'
  t.ruby_opts << '-rubygems'
  t.verbose = true
end

Rake::TestTask.new(:test_remote) do |t|
  t.pattern = 'test/remote_tests/*_test.rb'
  t.ruby_opts << '-rubygems'
  t.verbose = true
end

# Genereate the RDoc documentation
Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_dir = 'doc'
  rdoc.title    = "ActiveMerchant library"
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README', 'CHANGELOG')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

task :install => [:package] do
  `gem install pkg/#{PKG_FILE_NAME}.gem`
end

task :lines do
  lines = 0
  codelines = 0
  Dir.foreach("lib") { |file_name| 
    next unless file_name =~ /.*rb/

    f = File.open("lib/" + file_name)

    while line = f.gets
      lines += 1
      next if line =~ /^\s*$/
      next if line =~ /^\s*#/
      codelines += 1
    end
  }
  puts "Lines #{lines}, LOC #{codelines}"
end

# Publish beta gem  
desc "Publish the beta gem"
task :publish => [:rdoc, :package] do
  Rake::SshFilePublisher.new("leetsoft.com", "dist/pkg", "pkg", "#{PKG_FILE_NAME}.zip").upload
  Rake::SshFilePublisher.new("leetsoft.com", "dist/pkg", "pkg", "#{PKG_FILE_NAME}.tgz").upload
  Rake::SshFilePublisher.new("leetsoft.com", "dist/gems", "pkg", "#{PKG_FILE_NAME}.gem").upload
  `ssh tobi@leetsoft.com "mkdir -p dist/api/#{PKG_NAME}"`
  Rake::SshDirPublisher.new("leetsoft.com", "dist/api/#{PKG_NAME}", "doc").upload
  `ssh tobi@leetsoft.com './gemupdate'`
end

desc "Delete tar.gz / zip / rdoc"
task :cleanup => [ :rm_packages, :clobber_rdoc ]

task :install => [:package] do
  `gem install pkg/#{PKG_FILE_NAME}.gem`
end

spec = Gem::Specification.new do |s|
  s.name = PKG_NAME
  s.version = PKG_VERSION
  s.summary = "Library for using various geocoding APIs."
  s.has_rdoc = true

  s.files = %w(README MIT-LICENSE CHANGELOG) + Dir['lib/**/*']  

  s.require_path = 'lib'
  s.autorequire  = 'geocode'
  s.author = "Brandon Keepers"
  s.email = "brandon@opensoul.org"
  s.homepage = ""  
end

Rake::GemPackageTask.new(spec) do |p|
  p.gem_spec = spec
  p.need_tar = true
  p.need_zip = true
end

desc "Continuously watch unit tests"
task :watch do
  system("clear")
  system("stakeout \"rake\" `find . -name '*.rb'`")
end
