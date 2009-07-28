begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = 'backup'
    gemspec.author = "Nate Murray"
    gemspec.email = "nate@natemurray.com"
    gemspec.homepage = "http://tech.natemurray.com/backup"
    gemspec.platform = Gem::Platform::RUBY
    gemspec.summary = "Beginning-to-end solution for backups and rotation."
    gemspec.files = FileList["{bin,lib,tests,examples,doc}/**/*"].to_a
    gemspec.require_path = "lib"
    gemspec.test_files = FileList["{tests}/**/*test.rb"].to_a
    gemspec.bindir = "bin" # Use these for applications.
    gemspec.executables = ['backup']
    gemspec.default_executable = "backup"
    gemspec.has_rdoc = true
    gemspec.extra_rdoc_files = ["README", "CHANGELOG", "TODO", "Rakefile"]
    gemspec.rubyforge_project = "backupgem"
    gemspec.add_dependency("rake", ">= 0.7.1")
    gemspec.add_dependency("runt", ">= 0.3.0")
    gemspec.add_dependency("net-ssh", ">= 2.0.0")
    gemspec.add_dependency("madeleine", ">= 0.7.3")
  end
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end