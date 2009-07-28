# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{backup}
  s.version = "0.0.11"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Nate Murray"]
  s.date = %q{2009-07-28}
  s.default_executable = %q{backup}
  s.email = %q{nate@natemurray.com}
  s.executables = ["backup"]
  s.extra_rdoc_files = [
    "CHANGELOG",
     "Rakefile",
     "TODO"
  ]
  s.files = [
    "bin/backup",
     "bin/commands.sh",
     "doc/LICENSE-GPL.txt",
     "doc/index.html",
     "doc/styles.css",
     "examples/global.rb",
     "examples/mediawiki.rb",
     "examples/mediawiki_numeric.rb",
     "examples/s3.rb",
     "lib/backup.rb",
     "lib/backup/actor.rb",
     "lib/backup/cli.rb",
     "lib/backup/configuration.rb",
     "lib/backup/date_parser.rb",
     "lib/backup/extensions.rb",
     "lib/backup/recipes/standard.rb",
     "lib/backup/rotator.rb",
     "lib/backup/s3_helpers.rb",
     "lib/backup/ssh_helpers.rb",
     "lib/backup/state_recorder.rb",
     "tests/actor_test.rb",
     "tests/cleanup.sh",
     "tests/optional/s3_test.rb",
     "tests/rotation_test.rb",
     "tests/s3_test.rb",
     "tests/ssh_test.rb",
     "tests/tests_helper.rb"
  ]
  s.homepage = %q{http://tech.natemurray.com/backup}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{backupgem}
  s.rubygems_version = %q{1.3.4}
  s.summary = %q{Beginning-to-end solution for backups and rotation.}
  s.test_files = [
    "tests/actor_test.rb",
     "tests/optional/s3_test.rb",
     "tests/rotation_test.rb",
     "tests/s3_test.rb",
     "tests/ssh_test.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rake>, [">= 0.7.1"])
      s.add_runtime_dependency(%q<runt>, [">= 0.3.0"])
      s.add_runtime_dependency(%q<net-ssh>, [">= 2.0.0"])
      s.add_runtime_dependency(%q<madeleine>, [">= 0.7.3"])
    else
      s.add_dependency(%q<rake>, [">= 0.7.1"])
      s.add_dependency(%q<runt>, [">= 0.3.0"])
      s.add_dependency(%q<net-ssh>, [">= 2.0.0"])
      s.add_dependency(%q<madeleine>, [">= 0.7.3"])
    end
  else
    s.add_dependency(%q<rake>, [">= 0.7.1"])
    s.add_dependency(%q<runt>, [">= 0.3.0"])
    s.add_dependency(%q<net-ssh>, [">= 2.0.0"])
    s.add_dependency(%q<madeleine>, [">= 0.7.3"])
  end
end
