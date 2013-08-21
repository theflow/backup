Gem::Specification.new do |s|
  s.name              = "backup"
  s.version           = "0.2.0"
  s.summary           = "Beginning-to-end solution for backups and rotation."
  s.homepage          = "http://tech.natemurray.com/backup"
  s.authors           = ["Nate Murray", "Florian Munz"]
  s.email             = "nate@natemurray.com"
  s.executables       = ["backup"]

  s.rdoc_options      = ["--charset=UTF-8"]
  s.require_paths     = ["lib"]

  s.files             = `git ls-files`.split("\n")
  s.test_files        = `git ls-files -- {test,spec,features}/*`.split("\n")

  s.add_dependency("rake", "~> 10.1.0")
  s.add_dependency("runt", "~> 0.9.0")
  s.add_dependency("net-ssh", "~> 2.6.8")
  s.add_dependency("madeleine", "~> 0.8.0")
  s.add_dependency("aws-sdk", "~> 1.15.0")
end
