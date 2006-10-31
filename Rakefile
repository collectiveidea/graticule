require 'rubygems'
require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'rake/gempackagetask'
require 'rake/contrib/rubyforgepublisher'


PKG_VERSION = "0.1.0"
PKG_NAME = "graticule"
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
  rdoc.title    = "Graticule Geocoding Library"
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

desc "Publish the gem"
task :publish => [:rdoc, :package] do
  Rake::SshFilePublisher.new("host.collectiveidea.com", "/var/www/vhosts/source.collectiveidea.com/public/dist/pkg", "pkg", "#{PKG_FILE_NAME}.zip").upload
  Rake::SshFilePublisher.new("host.collectiveidea.com", "/var/www/vhosts/source.collectiveidea.com/public/dist/pkg", "pkg", "#{PKG_FILE_NAME}.tgz").upload
  Rake::SshFilePublisher.new("host.collectiveidea.com", "/var/www/vhosts/source.collectiveidea.com/public/dist/gems", "pkg", "#{PKG_FILE_NAME}.gem").upload
  `ssh host.collectiveidea.com "mkdir -p /var/www/vhosts/source.collectiveidea.com/public/dist/api/#{PKG_NAME}"`
  Rake::SshDirPublisher.new("host.collectiveidea.com", "/var/www/vhosts/source.collectiveidea.com/public/dist/api/#{PKG_NAME}", "doc").upload
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

  s.files = %w(README LICENSE CHANGELOG) + Dir['lib/**/*']  

  s.has_rdoc = true
  s.extra_rdoc_files = %w( README )
  s.rdoc_options.concat ['--main',  'README']
  
  s.require_path = 'lib'
  s.autorequire  = 'graticule'
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
