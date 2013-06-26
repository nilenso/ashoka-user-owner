$:.push File.expand_path("../lib", __FILE__)
require "req_conf/version"

Gem::Specification.new do |s|
  s.name        = "req_conf"
  s.version     = ReqConf::VERSION
  s.authors     = ["Jithu Gopal", "Timothy Andrew"]
  s.email       = ["jithu@nilenso.com", "tim@nilenso.com"]
  s.homepage    = "http://nilenso.com"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2.11"
  s.add_development_dependency "pg"
end
