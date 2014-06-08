# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'iremocon_control/version'

Gem::Specification.new do |spec|
  spec.name          = "iremocon_control"
  spec.version       = IRemoconControl::VERSION
  spec.authors       = ["YutaTanaka"]
  spec.email         = ["yuta84q.ihcarok@gmail.com"]
  spec.summary       = "iRemoconをコントロールします。"
  spec.description   = <<-'EOS'
  iRemoconに各種コマンドを送ることでコントロールします。
  赤外線送信、タイマ登録など一通りの機能を備えています。
  Unixコマンド"iremocon"からコントロールすることもできます。
  ネットワーク上からiRemoconを探す機能も備えており、ほとんど設定なしで利用できます。
  EOS
  spec.homepage      = "https://github.com/84q/iremocon_control"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = nil
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  
  spec.required_ruby_version = '>= 2.0'
end
