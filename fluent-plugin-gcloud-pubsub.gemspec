# encoding: utf-8
$:.push File.expand_path('../lib', __FILE__)

Gem::Specification.new do |gem|
  gem.name        = "fluent-plugin-cloud-pubsub"
  gem.description = "Fluentd plugin for sending data to Cloud Pub/Sub"
  gem.license     = "MIT"
  gem.homepage    = "https://github.com/yosssi/fluent-plugin-cloud-pubsub"
  gem.summary     = gem.description
  gem.version     = "0.0.2"
  gem.authors     = ["Keiji Yoshida"]
  gem.email       = "yoshida.keiji.84@gmail.com"
  gem.has_rdoc    = false
  gem.files       = `git ls-files`.split("\n")
  gem.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.executables = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.require_paths = ['lib']

  gem.add_runtime_dependency "fluentd", "~> 0.12.0"
  gem.add_runtime_dependency "gcloud", "~> 0.3.0"
  gem.add_runtime_dependency "yajl-ruby", "~> 1.0"

  gem.add_development_dependency "bundler"
  gem.add_development_dependency "rake"
  gem.add_development_dependency "test-unit"
end
