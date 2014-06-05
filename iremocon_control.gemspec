# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'iremocon_control/version'

Gem::Specification.new do |spec|
  spec.name          = "iremocon_control"
  spec.version       = IRemoconControl::VERSION
  spec.authors       = ["YutaTanaka"]
  spec.email         = ["yuta84q.ihcarok@gmail.com"]
  spec.summary       = "send commands to iremocon"
  spec.description   = "send commands to iremocon"
  spec.homepage      = "https://github.com/84q/iremocon_control"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = nil
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
